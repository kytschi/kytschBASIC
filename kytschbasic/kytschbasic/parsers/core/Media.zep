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
	protected id = "";
	protected _class = "";
	protected alt = "";
	protected src = "";

	public function parse(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		var controller;
		let controller = new Args();
		if (this->match(command, "IMAGE")) {
			var args = controller->parseShort("IMAGE", command);

			var arg, return_string = "<img";

			let this->id = this->genID("kb-img");

			if (isset(args[0])) {
				if (strpos(args[0], "\"") === 0) {
					let arg = controller->clean(args[0]);
				} else {
					let arg = "<?= " . this->parseVar(args[0]) . ";?>";
				}
				if (!empty(arg)) {
					let this->src = arg;
				
					if (!empty(config["cache"])) {
						if (empty(config["cache"]->enabled)) {
							let this->src = this->src . "?no-cache=" . microtime();
						}
					}

					let return_string = return_string . " src=\"" . this->src . "\"";
				}
			}

			if (isset(args[1])) {
				let arg = controller->clean(args[1]);
				if (!empty(arg)) {
					let this->alt = arg;
					let return_string = return_string . " alt=\"" . this->alt . "\"";
				}
			}

			if (isset(args[2])) {
				let arg = controller->clean(args[2]);
				if (!empty(arg)) {
					let this->_class = arg;
					let return_string = return_string . " class=\"" . this->_class . "\"";
				}
			}

			if (isset(args[3])) {
				let arg = controller->clean(args[3]);
				if (!empty(arg)) {
					let this->id = arg;

				}
			}

			return return_string . " id=\"" . this->id . "\">";
		}

		return null;
	}
}
