/**
 * Websocket parser
 *
 * @package     KytschBASIC\Parsers\Core\Communication\Websocket
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
use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Communication\Websocket\Chat;

class Websocket extends Command
{
	public function parse(string line, string command, array args)
	{
		var controller;

		let controller = new Chat();

		switch (command) {
			case "CHAT":
				return controller->chat("Testing");
			case "CHATLISTEN":
				return controller->listen();
			default:
				return null;
			
		}
	}
}