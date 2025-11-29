/**
 * WINDOW parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Screen\Window
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.2
 *
 * Copyright 2025 Mike Welsh
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
namespace KytschBASIC\Libs\Arcade\Parsers\Screen;

use KytschBASIC\Parsers\Core\Command;

class Window extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false)
	{
		switch(command) {
			case "WINDOW":
				return this->parseWindow(args);
			case "END WINDOW":
				return "</div>";
			default:
				return null;
		}
	}

	public function parseWindow(array args)
	{
		var output = "<?= \"<div", cleaned = "";

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= " id=" . this->outputArg(args[0]);
		} else {
			let output .= " id=" . this->outputArg(this->genID("kb-window"), true);
		}

		if (isset(args[1]) && !empty(args[1])) {
			let output .= " class=" . this->outputArg(args[1]);
		}

		if (isset(args[2]) && !empty(args[2])) {
			if (substr(args[2], 0, 1) == "\"") {
				let cleaned = trim(args[2], "\"");
			} else {
				let cleaned = this->outputArg(args[2], false);
			}

			let output .= " onclick='javascript:" . cleaned . "(event)'";
		}

		if (isset(args[3]) && !empty(args[3])) {
			if (substr(args[3], 0, 1) == "\"") {
				let cleaned = trim(args[3], "\"");
			} else {
				let cleaned = this->outputArg(args[3], false);
			}

			let output .= " ondblclick='javascript:" . cleaned . "(event)'";
		}
		
		return output . ">\"; ?>";
	}
}
