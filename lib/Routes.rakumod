use Cro::HTTP::Router;
use Cro::HTTP::Router::WebSocket;
use Cro::WebApp::Template;

sub routes() is export {
    route {
#        get -> {
#            content 'text/html', q:to/OPEN/;
#                <h1> raku-web-repl </h1>
#                <script src="js/local.js"></script>
#                <p>Type in some Raku code and click on Evaluate button</p>
#                <textarea rows=2 cols=30 id="raku-code"></textarea>
#                <button id="raku-button">Evaluate</button>
#                <div style="display: flex; flex-direction: horizontal;">
#                <div id="raku-ws-out"><p>Output</p></div>
#                <div id="raku-ws-err"><p>Errors</p></div>
#                </div>
#                OPEN
#
#        }
#
#        get -> 'js', *@path {
#            static 'static', @path
#        }
#
#        get -> 'favicon.ico' {
#            static 'static/favicon.ico'
#        }
        get -> 'raku' {
            web-socket :json, -> $incoming {
                supply whenever $incoming -> $message {
                    my $json = await $message.body;
                    if $json<code> {
                        my $proc = run $*EXECUTABLE.absolute, '-e', $json<code>,
                            :cwd<blank>, :out, :err;
                        my $stdout = $proc.out.slurp(:close);
                        $stdout = '｢no stdout｣' unless $stdout;
                        my $stderr = $proc.err.slurp(:close);
                        if $stderr {
                            $stderr .= subst(/ "\e[" \d+ 'm' /, '', :g)
                        }
                        else { $stderr = '｢no stderr｣' };
                        emit({ :$stdout, :$stderr })
                    }
                }
            }
        }
    }
}