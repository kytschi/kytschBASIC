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

class Chat
{
    protected clients;

    /*public function __construct()
    {
        let this->clients = new \SplObjectStorage;
    }

    public function onOpen(conn)
    {
        // Store the new connection to send messages to later
        this->clients->attach(conn);

        echo "New connection! ({conn->resourceId})\n";
    }

    public function onMessage(from, msg)
    {
        var client, num_recieved;

        let num_recieved = count(this->clients) - 1;

        echo sprintf(
            "Connection %d sending message '%s' to %d other connection%s\n",
            from->resourceId,
            msg,
            num_recieved,
            num_recieved == 1 ? "" : "s"
        );

        for client in this->clients {
            if (from !== client) {
                // The sender is not the receiver, send to each client connected
                client->send(msg);
            }
        }
    }

    public function onClose(conn)
    {
        // The connection is closed, remove it, as we can no longer send it messages
        this->clients->detach(conn);

        echo "Connection {conn->resourceId} has disconnected\n";
    }

    public function onError(conn, err)
    {
        echo "An error has occurred: {err->getMessage()}\n";
        conn->close();
    }*/
}