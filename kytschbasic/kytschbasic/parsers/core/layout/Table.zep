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
	protected id = "";
	protected _class = "";
	protected width = "";

	public function parse(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (this->match(command, "TABLE CLOSE")) {
			return "</table>";
		} elseif (this->match(command, "TABLE")) {
			return this->processTag("TABLE", "table", command, event_manager, globals);
		} elseif (this->match(command, "TBODY CLOSE")) {
			return "</tbody>";
		} elseif (this->match(command, "TBODY")) {
			return this->processTag("TBODY", "tbody", command, event_manager, globals);
		} elseif (this->match(command, "TCELL CLOSE")) {
			return "</td>";
		} elseif (this->match(command, "TCELL")) {
			return this->processCell("TCELL", "td", command, event_manager, globals);
		} elseif (this->match(command, "TFOOT CLOSE")) {
			return "</tfoot>";
		} elseif (this->match(command, "TFOOT")) {
			return this->processTag("TFOOT", "tfoot", command, event_manager, globals);
		} elseif (this->match(command, "THEADCELL CLOSE")) {
			return this->output("</th>");
		} elseif (this->match(command, "THEADCELL")) {
			return this->processCell("THEADCELL", "th", command, event_manager, globals);
		} elseif (this->match(command, "THEAD CLOSE")) {
			return "</thead>";
		} elseif (this->match(command, "THEAD")) {
			return this->processTag("THEAD", "thead", command, event_manager, globals);
		} elseif (this->match(command, "TROW CLOSE")) {
			return "</tr>";
		} elseif (this->match(command, "TROW")) {
			return this->processTag("TROW", "tr", command, event_manager, globals);
		}

		return null;
	}

	private function processCell(
		string command,
		string tag,
		string line,
		event_manager,
		array globals
	) {
		let this->id = this->genID("kb-" . tag);

		var args, arg, params="", controller;
		let controller = new Args();
		let args = controller->parseShort(command, line);

		if (isset(args[0])) {
			let arg = controller->clean(args[0]);
			if (!empty(arg)) {
				let this->width = arg;
				let params = params . " width=\"" . this->width . "\"";
			}
		}

		if (isset(args[1])) {
			let arg = controller->clean(args[1]);
			if (!empty(arg)) {
				let this->_class = arg;
				let params = params . " class=\"" . this->_class . "\"";
			}
		}

		if (isset(args[2])) {
			let arg = controller->clean(args[2]);
			if (!empty(arg)) {
				let params = params . " colspan=\"" . intval(arg) . "\"";
			}
		}

		if (isset(args[3])) {
			let arg = controller->clean(args[3]);
			if (!empty(arg)) {
				let this->id = arg;
			}
		}

		let params = params . " id=\"" . this->id . "\"";

		let params = params . controller->leftOver(3, args);

		return "<" . tag . " " . params . ">";
	}

	private function processTag(
		string command,
		string tag,
		string line,
		event_manager,
		array globals
	) {
		let this->id = this->genID("kb-" . tag);

		var args, arg, params="", controller;
		let controller = new Args();
		let args = controller->parseShort(command, line);

		if (isset(args[0])) {
			let arg = controller->clean(args[0]);
			if (!empty(arg)) {
				let this->_class = arg;
				let params = params . " class=\"" . this->_class . "\"";
			}
		}

		if (isset(args[1])) {
			let arg = controller->clean(args[1]);
			if (!empty(arg)) {
				let this->id = arg;
			}
		}

		let params = params . " id=\"" . this->id . "\"";

		let params = params . controller->leftOver(2, args);

		return "<" . tag . " " . params . ">";
	}
}
