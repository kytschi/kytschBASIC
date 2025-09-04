/**
 * Chat parser
 *
 * @package     KytschBASIC\Parsers\Core\Communication\Websocket\Chat
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

use KytschBASIC\Exceptions\Exception;
use Swoole\Coroutine\Http\Client;

class Chat
{
    protected client;
    protected config;
    protected url;

    private connected = false;

    public function __construct()
    {
        let this->config = constant("CONFIG");

        if (empty(this->config["websocket"])) {
			throw new Exception("No websocket configuration found", 400, false);
		}

		let this->config = this->config["websocket"];

        let this->url = (this->config->secure ? "wss://" : "ws://") .
            this->config->host .
            ":" . this->config->port;
    }

    public function broadcast(string message)
    {
        return this->sendJson([
            "type": "broadcast",
            "data": message
        ]);
    }

    public function chat(string message)
    {
        return this->sendJson([
            "type": "chat",
            "data": message
        ]);
    }

    public function connect()
    {
        var err, html = "";

        try {

            let html = "<?php 
                $KB_WS_CLIENT = new Swoole\\Coroutine\\Http\\Client('" . 
                    this->config->host . "', 
                    " . this->config->port . ",
                    " . this->config->secure . ");\n";
            let html .= "$KB_WS_CLIENT->upgrade('" .this->config->path . "');\n";
            let html .= "$KB_WS_CONNECTED = true;\n";
            let html .= "$KB_WS_CLIENT->setHeaders([
                'User-Agent' => 'kytschBASIC-WebSocket-Client/0.1',
                'Origin' => 'https://" . this->config->host . "'" .
            "]); ?>";
            return html;
        } catch Exception, err {
            return "<?php throw new KytschBASIC\\Exceptions\\Exception(
                'Connection error: " . err->getMessage() . ", Error: " . this->client->errCode . "
            ); ?>";
        }        
    }
    
    public function disconnect()
    {
        return "if ($KB_WS_CONNECTED) {$KB_WS_CONNECTED = false;\n $KB_WS_CLIENT->close();}";
    }

    public function handleMessage(string message)
    {
        var data;
        let data = json_decode(message, true);
        
        if (data) {
            if (isset(data->type)) {
                switch (data->type) {
                    case "welcome":
                        echo "Server: " . data->data . " (Client ID: " . data->connection_id . ")\n";
                        break;
                    case "chat":
                        echo "Chat message from " . (isset data->from ? data->from : "unknown") . ": " . data->message . "\n";
                        break;
                    case "broadcast":
                        echo "Broadcast from " . (isset data->from ? data->from : "unknown") . ": " . data->message . "\n";
                        break;
                    case "user_left":
                        echo "User " . data->user_id . " left the chat\n";
                        break;
                    default:
                        echo "Received: " . message . "\n";
                }
            } else {
                echo "Received: " . message . "\n";
            }
        } else {
            echo "Received: " . message . "\n";
        }
    }

    public function listen()
    {
        if (!this->connected) {
            echo "Not connected to server\n";
            return;
        }
        
        echo "Listening for messages... (Press Ctrl+C to stop)\n";
        
        while (this->connected) {
            var message;
            let message = this->receive(0.1);
            
            if (message) {
                this->handleMessage(message);
            }
            
            // Small delay to prevent CPU overload
            usleep(10000);
        }
    }

    public function receive(float timeout = 1.0)
    {
        if (!this->connected) {
            return null;
        }
        
        var frame;
        let frame = this->client->recv(timeout);
        
        if (frame) {
            return frame->data;
        }
        
        return null;
    }

    public function send(string message)
    {
        var html = "";

        if (!this->connected) {
            let html .= this->connect();
        }

        return html . "<?php $KB_WS_CLIENT->push('". message . "');\n " . this->disconnect() . " ?>";
    }

    public function sendJson(array data)
    {
        return this->send(json_encode(data));
    }
}