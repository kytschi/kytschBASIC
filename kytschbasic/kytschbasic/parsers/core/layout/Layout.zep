/**
 * Layout parser
 *
 * @package     KytschBASIC\Parsers\Core\Layout\Layout
 * @author 		Mike Welsh
 * @copyright   2023 Mike Welsh
 * @version     0.0.2
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
	protected id = "";
	protected _class = "";

	public function parse(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (this->match(command, "DIV CLOSE")) {
			return "</div>";
		} elseif (this->match(command, "DIV")) {
			return this->processTag("div", command, event_manager, globals);
		} elseif (this->match(command, "BODY CLOSE")) {
			return "</body>";
		} elseif (this->match(command, "BODY")) {
			return this->processTag("body", command, event_manager, globals);
		} elseif (this->match(command, "FOOTER CLOSE")) {
			return "</footer>";
		} elseif (this->match(command, "FOOTER")) {
			return this->processTag("footer", command, event_manager, globals);
		} elseif (this->match(command, "HEADER CLOSE")) {
			return "</header>";
		} elseif (this->match(command, "HEADER")) {
			return this->processTag("header", command, event_manager, globals);
		} elseif (this->match(command, "MAIN CLOSE")) {
			return "</main>";
		} elseif (this->match(command, "MAIN")) {
			return this->processTag("main", command, event_manager, globals);
		}

		return null;
	}

	private function processTag(
		string tag,
		string command,
		event_manager,
		array globals
	) {
		let this->id = this->genID("kb-" . tag);

		var args, arg, params="", controller;
		let controller = new Args();
		let args = controller->parseShort(strtoupper(tag), command);

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
