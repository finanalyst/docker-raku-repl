// @connect
// Connect to the websocket
let socket;
// This will let us create a connection to our Server websocket.
// For this to work, your websocket needs to be running with node index.js
const connect = function() {
    // Return a promise, which will wait for the socket to open
    return new Promise((resolve, reject) => {
        // This calculates the link to the websocket.
        const socketProtocol = (window.location.protocol === 'https:' ? 'wss:' : 'ws:')
        const port = 35154;
        const socketUrl = `${socketProtocol}//${window.location.hostname}:${port}/raku`;
        socket = new WebSocket(socketUrl);

        // This will fire once the socket opens
        socket.onopen = (e) => {
            // Send a little test data, which we can use on the server if we want
            socket.send(JSON.stringify({ "loaded" : true }));
            // Resolve the promise - we are connected
            resolve();
        }

        // This will fire when the server sends the user a message
        socket.onmessage = (data) => {
            let parsedData = JSON.parse(data.data);
            const resOut = document.createElement('p');
            const resErr = document.createElement('p');
            resOut.textContent = parsedData.result;
            resErr.textContent = parsedData.error;
            document.getElementById('raku-ws-out').appendChild(resOut);
            document.getElementById('raku-ws-err').appendChild(resErr);
        }
        // This will fire on error
        socket.onerror = (e) => {
            // Return an error if any occurs
            console.log(e);
            resolve();
            // Try to connect again
            connect();
        }
    });
}

// @isOpen
// check if a websocket is open
const isOpen = function(ws) {
    return ws.readyState === ws.OPEN
}

// When the document has loaded
document.addEventListener('DOMContentLoaded', function() {
    // Connect to the websocket
    connect();
    // And add our event listeners
    document.getElementById('raku-button').addEventListener('click', function(e) {
        let code = document.getElementById('raku-code').value;
        console.log(code);
        if(isOpen(socket)) {
            socket.send(JSON.stringify({
                "code" : code
            }))
        }
    });
});
