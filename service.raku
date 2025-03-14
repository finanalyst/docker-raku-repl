use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Cro::HTTP::Router;
use Cro::HTTP::Router::WebSocket;

my $host = %*ENV<RAKU_WEB_REPL_HOST> // '0.0.0.0';
my $port = %*ENV<RAKU_WEB_REPL_PORT> // 40005;
my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1>,
    :$host,
    :$port,
    application => routes(),
    after => [
        Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
    );
$http.start;
react {
    whenever signal(SIGINT) {
        $http.stop;
        done;
    }
}
sub routes() {
    route {
        get -> 'raku_repl' {
            web-socket :json, -> $incoming {
                supply whenever $incoming -> $message {
                    my $json = await $message.body;
                    if $json<code> {
                        my $proc = run $*EXECUTABLE.absolute, '-e', $json<code>,
                            :out, :err;
                        my $stdout = $proc.out.slurp(:close);
                        $stdout = '' unless $stdout;
                        my $stderr = $proc.err.slurp(:close);
                        if $stderr {
                            $stderr .= subst(/ "\e[" \d+ 'm' /, '', :g)
                        }
                        else { $stderr = '' };
                        emit({ :$stdout, :$stderr })
                    }
                    if $json<loaded> {
                        emit({ :connection<Confirmed> })
                    }
                }
            }
        }
    }
}
