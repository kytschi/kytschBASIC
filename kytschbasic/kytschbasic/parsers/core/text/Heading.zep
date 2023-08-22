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
	protected id = "";
	protected _class = "";

	private end = "";
	private size = 1;

	public function parse(
		string command,		
		event_manager = null,
		array globals = [],
		var config = null
	) {
		var controller;
		let controller = new Args();

		if (this->match(command, "HEADING CLOSE")) {
			return this->end;
		} elseif (this->match(command, "HEADING")) {
			var args, arg, params="";

			let this->id = this->genID("kb-heading");

			let args = this->parseArgs("HEADING", command);

			if (empty(args)) {
				let this->end = "</h1>";
				return "<h1>";
			}

			if (isset(args[0])) {
				let this->size = intval(controller->clean(args[0]));
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
					let this->id = arg;
				}
			}

			let params = params . " id=\"" . this->id . "\"";

			let this->end = this->output("</h" . this->size . ">");

			let params = params . controller->leftOver(1, args);

			return "<h" . this->size . params . ">";
		}

		return null;
	}
}
