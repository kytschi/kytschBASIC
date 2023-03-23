/**
 * Media parser
 *
 * @package     KytschBASIC\Parsers\Core\Media
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
namespace KytschBASIC\Parsers\Core;

use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Command;

class Media extends Command
{
	protected static id = "";
	protected static _class = "";
	protected static alt = "";
	protected static src = "";

	public static function parse(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (substr(command, 0, 5) == "IMAGE") {
			var args = Args::parseShort("IMAGE", command);

			var arg, return_string = "<img";

			let self::id = self::genID("kb-img");

			if (isset(args[0])) {
				let arg = Args::clean(args[0]);
				if (!empty(arg)) {
					let self::src = arg;
				
					if (!empty(config["cache"])) {
						if (empty(config["cache"]->enabled)) {
							let self::src = self::src . "?no-cache=" . microtime();
						}
					}

					let return_string = return_string . " src=\"" . self::src . "\"";
				}
			}

			if (isset(args[1])) {
				let arg = Args::clean(args[1]);
				if (!empty(arg)) {
					let self::alt = arg;
					let return_string = return_string . " alt=\"" . self::alt . "\"";
				}
			}

			if (isset(args[2])) {
				let arg = Args::clean(args[2]);
				if (!empty(arg)) {
					let self::_class = arg;
					let return_string = return_string . " class=\"" . self::_class . "\"";
				}
			}

			if (isset(args[3])) {
				let arg = Args::clean(args[3]);
				if (!empty(arg)) {
					let self::id = arg;

				}
			}

			return return_string . " id=\"" . self::id . "\">";
		}

		return null;
	}
}
