/**
 * AFUNCTION parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\AFunction
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
namespace KytschBASIC\Libs\Arcade\Parsers;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class AFunction extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false)
	{
		switch(command) {
			case "AFUNCTION":
				return this->parseFunction(line, args);
			case "ANIMATION":
				return this->parseFunction(line, args, true);
			case "ASYNCFUNCTION":
				return this->parseFunction(line, args, false, true);
			case "END AFUNCTION":
				return "}</script>";
			case "END ANIMATION":
				return "}</script>";
			case "END ASYNCFUNCTION":
				return "}</script>";
			case "SHOW":
				return this->parseShow(line, args, in_javascript);
			case "HIDE":
				return this->parseShow(line, args, in_javascript, true);
			default:
				return null;
		}
	}

	private function parseFunction(string line, array args, bool animation = false, bool async = false)
	{
		var output = "<script type=\"text/javascript\">", key, str, splits, arg, args;

		if (empty(args) || args[0] == "\"\"") {
			if (!animation) {
				throw new Exception("Invalid " . (async ? "ASYNCFUNCTION" : "AFUNCTION"));
			} else {
				let args[0] = "KB_ANIMATION_" . rand(10000, getrandmax());
			}
		}

		let args[0] = trim(args[0], "\"");
		if (substr(args[0], 0, 1) == "$") {
			let args[0] = "<?= " . args[0] . "; ?>";
		}

		if (animation) {
			let output .= "$(document).ready(function() {" . args[0] . "();});";
		}
		if (async || animation) {
			let output .= "async ";
		}
		let output .= "function " . args[0] . "(event";
		array_shift(args);

		for arg in args {
			let arg = trim(trim(arg), "\"");

			let output .= ",  ";

			let splits = preg_split("/=\\$(?=(?:[^\"']*[\"'][^\"']*[\"'])*[^\"']*$)/", arg, -1, PREG_SPLIT_NO_EMPTY | PREG_SPLIT_DELIM_CAPTURE);
			if (count(splits) > 1) {
				for key, str in splits {
					if (!key) {
						let output .= str . "=";
					} else {
						let output .= "'<?= $" . str . "; ?>'";
					}
				}
			} else {
				let output .= arg;
			}
		}

		return output . ") {\n";
	}

	private function parseShow(string line, array args, bool in_javascript = false, bool hide = false)
	{
		var output = "";

		if (!in_javascript) {
			let output = "<script type='text/javascript'>\n";
		}

		if (substr(args[0], 0, 1) == "$") {
			let args[0] = "<?= " . args[0] . "; ?>";
		} else {
			let args[0] = trim(args[0], "\"");
		}

		if (!hide) {
			let output .= "\t$('#" . args[0] . "').show();\n";
		} else {
			let output .= "\t$('#" . args[0] . "').hide();\n";
		}

		if (!in_javascript) {
			let output .= "</script>";
		}

		return output;
	}
}
