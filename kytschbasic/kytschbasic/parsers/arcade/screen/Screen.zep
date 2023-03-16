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
	protected static id;

	public static function parse(
		string command,		
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (substr(command, 0, 12) == "SCREEN CLOSE") {
			return self::output("</div>");
		} elseif (substr(command, 0, 6) == "SCREEN") {
			var args = Args::parseShort("SCREEN", command);

			if (isset(args[0])) {
				let self::id = trim(args[0], "\"");
			} else {
				let self::id = self::genID("kb-screen");
			}

			self::save();

			return self::output("<div id=\"" . self::id . "\">");
		}

		return null;
	}

	public static function save()
	{
		var screens = Session::read("screens");

		if (!is_array(screens)) {
			let screens = [];
		}

		let screens[self::id] = new self();

		Session::write("screens", screens);
	}
}
