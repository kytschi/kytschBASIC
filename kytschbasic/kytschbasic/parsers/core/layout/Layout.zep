/**
 * Layout parser
 *
 * @package     KytschBASIC\Parsers\Core\Layout\Layout
 * @author 		Mike Welsh
 * @copyright   2023 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2023 Mike Welsh
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
namespace KytschBASIC\Parsers\Core\Layout;

use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Command;

class Layout extends Command
{
	protected static id = "";
	protected static _class = "";

	public static function parse(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (substr(command, 0, 9) == "DIV CLOSE") {
			return "</div>";
		} elseif (substr(command, 0, 3) == "DIV") {
			return self::processTag("div", command, event_manager, globals);
		} elseif (substr(command, 0, 10) == "BODY CLOSE") {
			return "</body>";
		} elseif (substr(command, 0, 4) == "BODY") {
			return self::processTag("body", command, event_manager, globals);
		} elseif (substr(command, 0, 12) == "FOOTER CLOSE") {
			return "</footer>";
		} elseif (substr(command, 0, 6) == "FOOTER") {
			return self::processTag("footer", command, event_manager, globals);
		} elseif (substr(command, 0, 12) == "HEADER CLOSE") {
			return "</header>";
		} elseif (substr(command, 0, 6) == "HEADER") {
			return self::processTag("header", command, event_manager, globals);
		} elseif (substr(command, 0, 10) == "MAIN CLOSE") {
			return "</main>";
		} elseif (substr(command, 0, 4) == "MAIN") {
			return self::processTag("main", command, event_manager, globals);
		}

		return null;
	}

	private static function processTag(
		string tag,
		string command,
		event_manager,
		array globals
	) {
		let self::id = self::genID("kb-" . tag);

		var args, arg, params="";
		let args = Args::parseShort(strtoupper(tag), command);

		if (isset(args[0])) {
			let arg = Args::clean(args[0]);
			if (!empty(arg)) {
				let self::_class = arg;
				let params = params . " class=\"" . self::_class . "\"";
			}
		}

		if (isset(args[1])) {
			let arg = Args::clean(args[1]);
			if (!empty(arg)) {
				let self::id = arg;
			}
		}

		let params = params . " id=\"" . self::id . "\"";

		let params = params . Args::leftOver(2, args);

		return "<" . tag . " " . params . ">";
	}
}
