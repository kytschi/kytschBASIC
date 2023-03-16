/**
 * For Loop parser
 *
 * @package     KytschBASIC\Parsers\Core\Loops\ForLoop
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
namespace KytschBASIC\Parsers\Core\Loops;

use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Session;

class ForLoop extends Command
{
	public static function parse(
		string line,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		var args;
		
		if (self::match(line, "FOR CLOSE")) {
			return "}";
		} elseif (self::match(line, "FOR")) {
			let args = self::parseSpaceArgs(line, "FOR");
			
			if (count(args) == 3) {
				if (strtolower(args[1]) == "in") {
					var param = str_replace(["&", "$", "%"], "", args[0]);
					return "foreach ($_SESSION['" . args[2] . "'] as $" . param . ") {";
				}
			}

			if (count(args) <= 2) {
				throw new \Exception("Invalid FOR loop structure");
			}

			var splits = explode("=", args[0]);
			if (count(splits) <= 1) {
				throw new \Exception("Invalid FOR loop structure");
			}

			var step = 1;			

			return "$" . splits[0] . " = " . intval(splits[1]) .
			";while($" . splits[0] . " <= " . intval(args[2]) . ") {$" . splits[0] . "_step = " . step . ";";
		} elseif (self::match(line, "NEXT")) {
			let args = self::parseSpaceArgs(line);
			if (count(args) == 1) {
				throw new \Exception("NEXT command with no value");
			}

			return "$" . args[1] . " += $" . args[1] . "_step;}";
		}

		return null;
	}
}