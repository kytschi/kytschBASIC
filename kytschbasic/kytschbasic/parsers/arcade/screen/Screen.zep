/**
 * SCREEN parser
 *
 * @package     KytschBASIC\Parsers\Arcade\Screen\Screen
 * @author 		Mike Welsh
 * @copyright   2022 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2022 Mike Welsh
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
namespace KytschBASIC\Parsers\Arcade\Screen;

use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Session;

class Screen extends Command
{
	protected id;

	public function parse(
		string command,		
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (this->match(command, "SCREEN CLOSE")) {
			return this->output("</div>");
		} elseif (this->match(command, "SCREEN")) {
			var controller;
			let controller = new Args();
			var args = controller->parseShort("SCREEN", command);

			if (isset(args[0])) {
				let this->id = trim(args[0], "\"");
			} else {
				let this->id = this->genID("kb-screen");
			}

			this->save();

			return this->output("<div id=\"" . this->id . "\">");
		}

		return null;
	}

	public function save()
	{
		var controller;
		let controller = new Session();
		var screens = controller->read("screens");

		if (!is_array(screens)) {
			let screens = [];
		}

		let screens[this->id] = new self();

		controller->write("screens", screens);
	}
}
