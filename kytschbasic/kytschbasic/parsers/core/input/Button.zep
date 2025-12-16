/**
 * Button parser
 *
 * @package     KytschBASIC\Parsers\Core\Input\Button
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
namespace KytschBASIC\Parsers\Core\Input;

use KytschBASIC\Parsers\Core\Command;

class Button extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch(command) {
			case "BUTTON":
				return this->processButton(args, false, in_event);
			case "BUTTONSUBMIT":
				return this->processButton(args, true, in_event);
			case "END BUTTON":
				return "</button>";
			default:
				return null;
		}
	}

	private function processButton(array args, bool submit = false, in_event = false)
	{
		var output = "<?= \"<button", type = "\"button\"";
		
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			if (submit) {
				let type = "\"submit\"";
			}
			let output .= " name=" . this->outputArg(args[0], false);
		} else {
			let output .= " name=" . this->outputArg(this->genID("kb-btn-submit"), false);
		}

		let output .= " type=" . this->outputArg(type);

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let output .= " class=" . this->outputArg(args[1], false);
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let output .= " id=" . this->outputArg(args[2], false);
		}

		if (isset(args[3]) && !empty(args[3]) && args[3] != "\"\"") {
			let output .= " value=" . this->outputArg(args[3], false);
		} else {
			let output .= " value='button'";
		}

		if (isset(args[5]) && !empty(args[5]) && args[5] != "\"\"") {
			let output .= " onclick=" . this->outputArg(args[5], false);
		} elseif (in_event) {
			if (isset(in_event[0]) && !empty(in_event[0]) && in_event[0] != "\"\"") {
				var str, splits = preg_split("/\'[^\']*\'(*SKIP)(*FAIL)|\K\(/", trim(in_event[0], "\""));
				if (splits) {
					if (isset(in_event[1]) && !empty(in_event[1]) && in_event[1] != "\"\"" && in_event[1] == "\"true\"") {
						let output .= " ondblclick=\\\"";
					} else {
						let output .= " onclick=\\\"";
					}
					let output .= splits[0] . "(event";
					array_shift(splits);
					for (str in splits) {
						if (str != ")") {
							let output .= ", " . str;
						} else {
							let output .= str;
						}
					}
				}
				let output = rtrim(output, ")") . ");\\\"";
			}
		}

		if (isset(args[4]) && !empty(args[4]) && args[4] != "\"\"") {
			let output .= "><span>" . this->outputArg(args[4], false, false) . "</span></button>";
		} else {
			let output .= ">";
		}

		return output . "\"; ?>";
	}
}
