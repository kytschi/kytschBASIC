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
	protected static id;
	protected static screen_id;

	protected static x1;
	protected static y1;
	protected static x2;
	protected static y2;

	protected static title;
	protected static type;

	public static function parse(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (substr(command, 0, 12) == "WINDOW CLOSE") {
			return self::output("</div>");
		} elseif (substr(command, 0, 6) == "WINDOW") {
			var args;
			let args = Args::parseShort("WINDOW", command);
			if (isset(args[0])) {
				let self::id = trim(args[0], "\"");
			} else {
				let self::id = self::genID("kb-window");
			}

			if (isset(args[1])) {
				let self::title = trim(args[1], "\"");
			}

			if (isset(args[2])) {
				var coords, splits;
				let coords = trim(args[2], "\"");
				let splits = explode("-", coords);

				if (isset(splits[0])) {
					let coords = explode(",", splits[0]);
					if (isset(coords[0])) {
						let self::x1 = intval(coords[0]);
					}

					if (isset(coords[1])) {
						let self::y1 = intval(coords[1]);
					}
				}

				if (isset(splits[1])) {
					let coords = explode(",", splits[1]);
					if (isset(coords[0])) {
						let self::x2 = intval(coords[0]);
					}

					if (isset(coords[1])) {
						let self::y2 = intval(coords[1]);
					}
				}
			}

			if (isset(args[3])) {
				let self::type = trim(args[3], "\"");
			}

			if (isset(args[4])) {
				let self::screen_id = trim(args[4], "\"");
			}

			self::save();

			var params;
			let params = "id=\"" . self::id . "\"";
			if (self::title) {
				let params = params . " title=\"" . self::title . "\"";
			}

			return self::output("<div " . params . ">");
		}

		return null;
	}

	public static function save()
	{
		var windows = Session::read("windows");

		if (!is_array(windows)) {
			let windows = [];
		}

		let windows[self::id] = new self();

		Session::write("windows", windows);
	}
}
