/**
 * Server parser
 *
 * @package     KytschBASIC\Parsers\Core\Communication\Websocket\Server
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.1
 *
 * Copyright 2025 Mike Welsh
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA  02110-1301, USA.
 */
namespace KytschBASIC\Parsers\Core\Communication\Websocket;

use KytschBASIC\Compiler;
use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Communication\Websocket\Chat;
use Swoole\WebSocket\Server as WSServer;
use Swoole\WebSocket\Frame;

class Server
{
    protected static server;
    protected static config;

    public function __construct(string config_dir)
    {
        var compiler, config = [];

        if (config_dir) {
            let compiler = new Compiler(config_dir, true);
		} else {
            throw new Exception("Missing config directory", 400, false);
        }

		let self::config = constant("CONFIG");

        if (empty(self::config["websocket"])) {
			throw new Exception("No websocket configuration found", 400, false);
		}

		let self::config = self::config["websocket"];

        if (self::config->debug) {
            let config["log_level"] = SWOOLE_LOG_DEBUG;
            let config["trace_flags"] = SWOOLE_TRACE_ALL;
        }

        if (self::config->secure) {
            let self::server = new WSServer(
                self::config->host,
                self::config->port,
                SWOOLE_PROCESS, SWOOLE_SOCK_TCP | SWOOLE_SSL
            );

            let config = [
                "ssl_cert_file": self::config->ssl_cert_file,
                "ssl_key_file": self::config->ssl_key_file
                //"ssl_verify_peer": self::config->ssl_verify_peer,
                //"ssl_allow_self_signed": self::config->ssl_allow_self_signed,
                //"ssl_prefer_server_ciphers": true,
                //"worker_num": 1
                //"ssl_ciphers": "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256"
                //"ssl_protocols": 32 | 64
            ];
        } else {
            let self::server = new WSServer(
                self::config->host,
                self::config->port
            );
        }

        if (count(config)) {
            self::server->set(config);
        }

        self::server->on(
            "start",
            "KytschBASIC\\Parsers\\Core\\Communication\\Websocket\\Server::start"
        );

        self::server->on(
            "open",
            "KytschBASIC\\Parsers\\Core\\Communication\\Websocket\\Server::open"
        );

        self::server->on(
            "message",
            "KytschBASIC\\Parsers\\Core\\Communication\\Websocket\\Server::message"
        );

        self::server->on(
            "request",
            "KytschBASIC\\Parsers\\Core\\Communication\\Websocket\\Server::request"
        );

        self::server->on(
            "close",
            "KytschBASIC\\Parsers\\Core\\Communication\\Websocket\\Server::close"
        );
                
        self::server->start();
    }
    
    private static function broadcast(server, frame, data, type = "chat", from = "server")
    {
        var connection;

        for connection in server->connections {
            if (server->isEstablished(connection)) {
                server->push(
                    connection,
                    json_encode(
                        [
                            "type": type,
                            "client_id": frame->fd,
                            "from": from,
                            "data": data,
                            "created_at": time()
                        ]
                    )
                );
            }
        }
    }

    public static function close(server, int client_id, data = null)
    {
        var connection;

        echo "Connection closed: " . connection . "\n";
                    
        // Notify other clients about disconnection
        for connection in self::server->connections {
            if (server->isEstablished(connection)) {
                server->push(
                    connection,
                    json_encode(
                        [
                            "type": "disconnect",
                            "client_id": client_id,
                            "data": "A user has disconnected"
                        ]
                    )
                );
            }
        }
    }

    public static function message(server, frame)
    {
        var data;

        echo "Received message from client_id: " . frame->fd . ", " . frame->data . "\n";
        
        // Parse the incoming JSON message
        let data = json_decode(frame->data, false);
        
        // Process different message types
        switch (data->type) {
            case "broadcast":
                self::broadcast(server, frame, data->data, "broadcast");
                break;
            case "chat":
                self::broadcast(server, frame, data->data);
                break;
            case "game":
                self::broadcast(server, frame, data, "game");
                break;
            default:
                echo "Unknown message type, " . data->type;
                break;
        }
    }

    public static function open(server, request)
    {
        echo "Connection opened: " . request->fd . "\n";
        
        // Send welcome message to client
        server->push(
            request->fd,
            json_encode(
                [
                    "type": "welcome",
                    "data": "Connected to WebSocket server",
                    "client_id": request->fd
                ]
            )
        );
    }

    public static function request(request, response)
    {
        response->header("Content-Type", "application/json");
        response->end(
            json_encode(
                [
                    "status": "success",
                    "data": "WebSocket Server is running",
                    "clients_count": self::server->connections->count()
                ]
            )
        );
    }

    public static function start(server)
    {
        echo "Swoole WebSocket Server is started at " .
            (self::config->secure ? "wss" : "ws") . "://" .
            self::config->host . ":" .
            self::config->port . "\n";
    }
}