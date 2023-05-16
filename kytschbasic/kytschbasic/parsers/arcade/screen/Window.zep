/**
 * WINDOW parser
 *
 * @package     KytschBASIC\Parsers\Arcade\Screen\Window
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

class Window extends Command
{
	protected id;
	protected screen_id;

	protected x1;
	protected y1;
	protected x2;
	protected y2;

	protected title;
	protected type;

	public function parse(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (this->match(command, "WINDOW CLOSE")) {
			return this->output("</div>");
		} elseif (this->match(command, "WINDOW")) {
			var args, controller;
			let controller = new Args();
			let args = controller->parseShort("WINDOW", command);
			if (isset(args[0])) {
				let this->id = trim(args[0], "\"");
			} else {
				let this->id = this->genID("kb-window");
			}

			if (isset(args[1])) {
				let this->title = trim(args[1], "\"");
			}

			if (isset(args[2])) {
				var coords, splits;
				let coords = trim(args[2], "\"");
				let splits = explode("-", coords);

				if (isset(splits[0])) {
					let coords = explode(",", splits[0]);
					if (isset(coords[0])) {
						let this->x1 = intval(coords[0]);
					}

					if (isset(coords[1])) {
						let this->y1 = intval(coords[1]);
					}
				}

				if (isset(splits[1])) {
					let coords = explode(",", splits[1]);
					if (isset(coords[0])) {
						let this->x2 = intval(coords[0]);
					}

					if (isset(coords[1])) {
						let this->y2 = intval(coords[1]);
					}
				}
			}

			if (isset(args[3])) {
				let this->type = trim(args[3], "\"");
			}

			if (isset(args[4])) {
				let this->screen_id = trim(args[4], "\"");
			}

			this->save();

			var params;
			let params = "id=\"" . this->id . "\"";
			if (this->title) {
				let params = params . " title=\"" . this->title . "\"";
			}

			return this->output("<div " . params . ">");
		}

		return null;
	}

	public function save()
	{
		var controller;
		let controller = new Session();

		var windows = controller->read("windows");

		if (!is_array(windows)) {
			let windows = [];
		}

		let windows[this->id] = new self();

		controller->write("windows", windows);
	}
}
