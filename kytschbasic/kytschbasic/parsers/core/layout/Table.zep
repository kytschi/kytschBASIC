/**
 * Table parser
 *
 * @package     KytschBASIC\Parsers\Core\Layout\Table
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

class Table extends Command
{
	protected static id = "";
	protected static _class = "";
	protected static width = "";

	public static function parse(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (self::match(command, "TABLE CLOSE")) {
			return "</table>";
		} elseif (self::match(command, "TABLE")) {
			return self::processTag("TABLE", "table", command, event_manager, globals);
		} elseif (self::match(command, "TBODY CLOSE")) {
			return "</tbody>";
		} elseif (self::match(command, "TBODY")) {
			return self::processTag("TBODY", "tbody", command, event_manager, globals);
		} elseif (self::match(command, "TCELL CLOSE")) {
			return "</td>";
		} elseif (self::match(command, "TCELL")) {
			return self::processCell("TCELL", "td", command, event_manager, globals);
		} elseif (self::match(command, "TFOOT CLOSE")) {
			return "</tfoot>";
		} elseif (self::match(command, "TFOOT")) {
			return self::processTag("TFOOT", "tfoot", command, event_manager, globals);
		} elseif (self::match(command, "THEADCELL CLOSE")) {
			return self::output("</th>");
		} elseif (self::match(command, "THEADCELL")) {
			return self::processCell("THEADCELL", "th", command, event_manager, globals);
		} elseif (self::match(command, "THEAD CLOSE")) {
			return "</thead>";
		} elseif (self::match(command, "THEAD")) {
			return self::processTag("THEAD", "thead", command, event_manager, globals);
		} elseif (self::match(command, "TROW CLOSE")) {
			return "</tr>";
		} elseif (self::match(command, "TROW")) {
			return self::processTag("TROW", "tr", command, event_manager, globals);
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

		return "<" . tag . " " . params . ">";
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

		return "<" . tag . " " . params . ">";
	}
}
