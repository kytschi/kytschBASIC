/**
 * Table parser
 *
 * @package     KytschBASIC\Parsers\Core\Layout\Table
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
namespace KytschBASIC\Parsers\Core\Layout;

use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Command;

class Table extends Command
{
	protected static id = "";
	protected static _class = "";
	protected static width = "";

	public static function parse(
		string line,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (substr(line, 0, 11) == "TABLE CLOSE") {
			return self::output("</table>");
		} elseif (substr(line, 0, 5) == "TABLE") {
			return self::processTag("TABLE", "table", line, event_manager, globals);
		} elseif (substr(line, 0, 11) == "TBODY CLOSE") {
			return self::output("</tbody>");
		} elseif (substr(line, 0, 5) == "TBODY") {
			return self::processTag("TBODY", "tbody", line, event_manager, globals);
		} elseif (substr(line, 0, 11) == "TCELL CLOSE") {
			return self::output("</td>");
		} elseif (substr(line, 0, 5) == "TCELL") {
			return self::processCell("TCELL", "td", line, event_manager, globals);
		} elseif (substr(line, 0, 11) == "TFOOT CLOSE") {
			return self::output("</tfoot>");
		} elseif (substr(line, 0, 5) == "TFOOT") {
			return self::processTag("TFOOT", "tfoot", line, event_manager, globals);
		} elseif (substr(line, 0, 15) == "THEADCELL CLOSE") {
			return self::output("</th>");
		} elseif (substr(line, 0, 9) == "THEADCELL") {
			return self::processCell("THEADCELL", "th", line, event_manager, globals);
		} elseif (substr(line, 0, 11) == "THEAD CLOSE") {
			return self::output("</thead>");
		} elseif (substr(line, 0, 5) == "THEAD") {
			return self::processTag("THEAD", "thead", line, event_manager, globals);
		} elseif (substr(line, 0, 10) == "TROW CLOSE") {
			return self::output("</tr>");
		} elseif (substr(line, 0, 4) == "TROW") {
			return self::processTag("TROW", "tr", line, event_manager, globals);
		}

		return null;
	}

	private static function processCell(
		string command,
		string tag,
		string line,
		event_manager,
		array globals
	) {
		let self::id = self::genID("kb-" . tag);

		var args, arg, params="";
		let args = Args::parseShort(command, line);

		if (isset(args[0])) {
			let arg = Args::clean(args[0]);
			if (!empty(arg)) {
				let self::width = arg;
				let params = params . " width=\"" . self::width . "\"";
			}
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
				let params = params . " colspan=\"" . intval(arg) . "\"";
			}
		}

		if (isset(args[3])) {
			let arg = Args::clean(args[3]);
			if (!empty(arg)) {
				let self::id = arg;
			}
		}

		let params = params . " id=\"" . self::id . "\"";

		let params = params . Args::leftOver(3, args);

		return self::output("<" . tag . " " . params . ">");
	}

	private static function processTag(
		string command,
		string tag,
		string line,
		event_manager,
		array globals
	) {
		let self::id = self::genID("kb-" . tag);

		var args, arg, params="";
		let args = Args::parseShort(command, line);

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

		return self::output("<" . tag . " " . params . ">");
	}
}
