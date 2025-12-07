/**
 * Table parser
 *
 * @package     KytschBASIC\Parsers\Core\Layout\Table
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
namespace KytschBASIC\Parsers\Core\Layout;

use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Command;

class Table extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch(command) {
			case "END TABLE":
				return "</table>";
			case "END TBODY":
				return "</tbody>";
			case "END TCELL":
				return "</td>";
			case "END TFOOT":
				return "</tfoot>";
			case "END THEAD":
				return "</thead>";
			case "END THEADCELL":
				return "</th>";
			case "END TROW":
				return "</tr>";
			case "TABLE":
				return this->processTag("table", args);
			case "TBODY":
				return this->processTag("tbody", args);
			case "TCELL":
				return this->processCell("td", args);
			case "TFOOT":
				return this->processTag("tfoot", args);
			case "THEAD":
				return this->processTag("thead", args);
			case "THEADCELL":
				return this->processCell("th", args);
			case "TROW":
				return this->processTag("tr", args);
			default:
				return null;
		}
	}

	private function processCell(string tag, array args)
	{
		var output = "<?= \"<";
				
		let output .= tag;

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= " width=" . this->outputArg(args[0]);
		}

		if (isset(args[1]) && !empty(args[1])) {
			let output .= " class=" . this->outputArg(args[1]);
		}

		if (isset(args[2]) && !empty(args[2])) {
			let output .= " colspan=" . this->outputArg(args[2]);
		}

		if (isset(args[3]) && !empty(args[3])) {
			let output .= " id=" . this->outputArg(args[3]);
		} else {
			let output .= " id=" . this->outputArg(this->genID("kb-" . tag), true);
		}
		
		return output . ">\"; ?>";
	}

	private function processTag(string tag, array args)
	{
		var output = "<?= \"<";

		let output .= tag;
		
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= " class=" . this->outputArg(args[0]);
		}

		if (isset(args[1]) && !empty(args[1])) {
			let output .= " id=" . this->outputArg(args[1]);
		} else {
			let output .= " id=" . this->outputArg(this->genID("kb-" . tag), true);
		}
		
		return output . ">\"; ?>";
	}
}
