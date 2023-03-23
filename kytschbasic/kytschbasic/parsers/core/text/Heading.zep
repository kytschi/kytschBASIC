/**
 * Heading parser
 *
 * @package     KytschBASIC\Parsers\Heading
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
namespace KytschBASIC\Parsers\Core\Text;

use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Command;

class Heading extends Command
{
	protected static id = "";
	protected static _class = "";

	private static end = "";
	private static size = 1;

	public static function parse(
		string command,		
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (substr(command, 0, 13) == "HEADING CLOSE") {
			return self::end;
		} elseif (substr(command, 0, 7) == "HEADING") {
			var args, arg, params="";

			let self::id = self::genID("kb-heading");

			let args = Args::parseShort("HEADING", command);

			if (empty(args)) {
				let self::end = "</h1>";
				return "<h1>";
			}

			if (isset(args[0])) {
				let self::size = intval(Args::clean(args[0]));
			}

			if (isset(args[1])) {
				let arg = Args::clean(args[1]);
				if (!empty(arg)) {
					let self::_class = arg;
					let params = params . " class=\"" . self::_class . "\"";
				}
			}

			if (isset(args[2])) {
				let arg = Args::clean(args[2]);
				if (!empty(arg)) {
					let self::id = arg;
				}
			}

			let params = params . " id=\"" . self::id . "\"";

			let self::end = self::output("</h" . self::size . ">");

			let params = params . Args::leftOver(1, args);

			return "<h" . self::size . params . ">";
		}

		return null;
	}
}
