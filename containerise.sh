#!/bin/sh
c=$(buildah from docker.io/croservices/cro-http-websocket)
buildah add $c service.raku /app
buildah commit --rm $c docker.io/finanalyst/raku-repl:latest
