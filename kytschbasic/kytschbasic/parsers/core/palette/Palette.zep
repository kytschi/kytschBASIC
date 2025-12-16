/**
 * Palette parser
 *
 * @package     KytschBASIC\Parsers\Core\Palette\Palette
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.1
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
namespace KytschBASIC\Parsers\Core\Palette;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Palette extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch(command) {
			case "BACKGROUND":
				return this->processBackground(args);
			case "COLOR":
				return this->processColor(args);
			case "END PALETTE":
				return "}</style>";
			case "HEIGHT":
				return this->processSize(args, false, "height");
			case "HEIGHTPERCENT":
				return this->processSize(args, true, "height");				
			case "PALETTE":
				return this->processPalette(args);
			case "WIDTH":
				return this->processSize(args);
			case "WIDTHPERCENT":
				return this->processSize(args, true);
			default:
				return null;
		}
	}

	private function processBackground(array args)
	{
		var output = "background-color: rgba(";

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= intval(args[0]) . ",";
		} else {
			let output .= "0,";
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let output .= intval(args[1]) . ",";
		} else {
			let output .= "0,";
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let output .= intval(args[2]) . ",";
		} else {
			let output .= "0,";
		}

		if (isset(args[3]) && !empty(args[3]) && args[3] != "\"\"") {
			let output .= (intval(args[3])/100) . ") !important;";
		} else {
			let output .= "1) !important;";
		}

		return output;
	}

	private function processColor(array args)
	{
		var output = "color: rgba(";

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= intval(args[0]) . ",";
		} else {
			let output .= "0,";
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let output .= intval(args[1]) . ",";
		} else {
			let output .= "0,";
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let output .= intval(args[2]) . ",";
		} else {
			let output .= "0,";
		}

		if (isset(args[3]) && !empty(args[3]) && args[3] != "\"\"") {
			let output .= (intval(args[3])/100) . ") !important;";
		} else {
			let output .= "1) !important;";
		}

		return output;
	}

	private function processPalette(array args)
	{
		var config, output = "", href;
		let config = constant("CONFIG");

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output = "<?= \"<link rel=" . this->outputArg("stylesheet", false);
			let output .= " type=" . this->outputArg("text/css", false);

			let href =  "rtrim(\"" . this->outputArg(args[0], false, false) . "\", \".css\") . \".css\\\"";
			
			if (!empty(config["cache"])) {
				if (empty(config["cache"]->enabled)) {
					let href .= "?no-cache=" . microtime();
				}
			}

			let output .= " href=\\\"\" . " . href;

			return output . ">\"; ?>";
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			return "<style>#" . this->outputArg(args[1], true, false) . "{";
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			return "<style>." . this->outputArg(args[2], true, false) . "{";
		}
	}

	private function processSize(array args, bool percent = false, string type = "width")
	{
		var output = "";

		let output = type . ": ";

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= "<?= intval(" . this->outputArg(args[0], false, false) . "); ?>";
			if (percent) {
				let output .= "%";
			} else {
				let output .= "px";
			}
			let output .= " !important;";
		} else {
			let output .= "100" . (percent ? "%" : "") . " !important;";
		}

		return output;
	}
}
