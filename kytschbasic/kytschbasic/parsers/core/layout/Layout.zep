/**
 * Layout parser
 *
 * @package     KytschBASIC\Parsers\Core\Layout\Layout
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.3
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
namespace KytschBASIC\Parsers\Core\Layout;

use KytschBASIC\Parsers\Core\Command;

class Layout extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch(command) {
			case "BODY":
				return this->processTag("body", args);
			case "DIV":
				return this->processTag("div", args);
			case "END":
				return "</html>";
			case "END BODY":
				return "</body>";
			case "END DIV":
				return "</div>";
			case "END FOOTER":
				return "</footer>";
			case "END HEADER":
				return "</header>";
			case "END MAIN":
				return "</main>";
			case "FOOTER":
				return this->processTag("footer", args);
			case "HEADER":
				return this->processTag("header", args);
			case "MAIN":
				return this->processTag("main", args);
			case "MOVETO":
				return this->processMoveTo(args);
			default:
				return null;
		}
	}

	private function processMoveTo(array args)
	{
		var output = "<style>";

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let output .= "#" . this->outputArg(args[2], true, false);
		}

		if (isset(args[3]) && !empty(args[3]) && args[3] != "\"\"") {
			let output .= "." . this->outputArg(args[3], true, false);
		}

		let output .= " {position: ";

		if (isset(args[4]) && !empty(args[4]) && args[4] != "\"\"") {
			if (strtoupper(trim(args[4], "\"")) == "TRUE") {
				let output .= "absolute;";
			} else {
				let output .= "relative;";
			}
		} else {
			let output .= "relative;";
		}
		
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= " left: " . this->outputArg(args[0], true, false) . "px;";
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let output .= " top: " . this->outputArg(args[1], true, false) . "px;";
		}
		
		return output . "}</style>";
	}

	private function processTag(string tag, array args)
	{
		var output = "<?= \"<";

		let output .= tag;
		
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= " class=" . this->outputArg(args[0], false);
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let output .= " id=" . this->outputArg(args[1], false);
		} else {
			let output .= " id=" . this->outputArg(this->genID("kb-" . tag), false);
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let output .= " " . str_replace(
				"\"",
				"\\\"",
				args[2]				
			);
		}
		
		return output . ">\"; ?>";
	}
}
