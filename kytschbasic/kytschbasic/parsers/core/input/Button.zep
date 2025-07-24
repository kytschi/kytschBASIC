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
	public function parse(string line, string command, array args)
	{
		switch(command) {
			case "BUTTON":
				return this->processButton(args);
			case "END BUTTON":
				return "</button>";
			default:
				return null;
		}
	}

	private function processButton(array args)
	{
		var output = "<?= \"<button", type = "\"button\"";
		
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			if (substr(args[0], 0, 6) == "SUBMIT") {
				let args[0] = this->cleanArg("SUBMIT ", args[0]);
				let type = "\"submit\"";
			}
			let output .= " name=" . this->outputArg(args[0]);
		} else {
			let output .= " name=" . this->outputArg(this->genID("kb-btn-submit"), true);
		}

		let output .= " type=" . this->outputArg(type);

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let output .= " class=" . this->outputArg(args[1]);
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let output .= " id=" . this->outputArg(args[2]);
		}

		if (isset(args[3]) && !empty(args[3]) && args[3] != "\"\"") {
			let output .= " value=" . this->outputArg(args[3]);
		} else {
			let output .= " value='button'";
		}

		if (isset(args[4]) && !empty(args[4]) && args[4] != "\"\"") {
			let output .= "><span>\" . " . args[4] . " . \"</span></button>";
		} else {
			let output .= ">";
		}

		return output . "\"; ?>";
	}
}
