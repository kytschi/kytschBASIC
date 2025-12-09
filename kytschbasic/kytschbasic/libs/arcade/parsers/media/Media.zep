/**
 * Media parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Media\Media
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
namespace KytschBASIC\Libs\Arcade\Parsers\Media;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Media extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch (command) {
			case "LOADMEDIA":
				return this->parseLoad(args);
			case "PLAYMEDIA":
				return this->parsePlay(args, in_javascript);
			default:
				return null;
		}
	}

	private function parseLoad(args)
	{
		var output = "<video ";

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let args[1] = trim(args[1], "\"");
			if (substr(args[1], 0, 1) != "$") {
				let args[1] = "\"" . args[1] . "\"";
			} else {
				let args[1] = "\"<?= " . args[1] . "; ?>\"";
			}
			let output .= "id=" . args[1] . " ";
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let args[2] = trim(args[2], "\"");
			if (substr(args[2], 0, 1) != "$") {
				let args[2] = "\"" . args[2] . "\"";
			} else {
				let args[2] = "\"<?= " . args[2] . "; ?>\"";
			}
			let output .= "class=" . args[2] . " ";
		}
		
		if (isset(args[3]) && !empty(args[3]) && args[3] != "\"\"") {
			let args[3] = trim(args[3], "\"");
			if (strtolower(args[3]) != "false") {
				let output .= "controls ";
			}
		} else {
			let output .= "controls ";
		}

		if (isset(args[4]) && !empty(args[4]) && args[4] != "\"\"") {
			let args[4] = trim(args[4], "\"");
			if (strtolower(args[4]) == "true") {
				let output .= "muted ";
			}
		}

		if (isset(args[5]) && !empty(args[5]) && args[5] != "\"\"") {
			let args[5] = trim(args[5], "\"");
			if (substr(args[5], 0, 1) != "$") {
				let args[5] = "\"" . args[5] . "\"";
			} else {
				let args[5] = "\"<?= " . args[5] . "; ?>\"";
			}
			let output .= "width=" . args[5] . " ";
		} else {
			let output .= "width=\"640\" ";
		}

		if (isset(args[6]) && !empty(args[6]) && args[6] != "\"\"") {
			let args[6] = trim(args[6], "\"");
			if (substr(args[6], 0, 1) != "$") {
				let args[6] = "\"" . args[6] . "\"";
			} else {
				let args[6] = "\"<?= " . args[6] . "; ?>\"";
			}
			let output .= "height=" . args[6] . " ";
		} else {
			let output .= "height=\"480\" ";
		}

		let output = trim(output) . ">";

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let args[0] = trim(args[0], "\"");
			if (substr(args[0], 0, 1) != "$") {
				let args[0] = "\"" . args[0] . "\"";
			} else {
				let args[0] = "\"<?= " . args[0] . "; ?>\"";
			}

			let output .= "<source src=" . args[0] . " type=\"<?= mime_content_type(constant(\"_ROOT\") . " . args[0] . "); ?>\" />";
		}
				
		return output . "</video>";
	}

	private function parsePlay(args, bool in_javascript = false)
	{
		var output = "";

		if (!in_javascript) {
			let output = "<script type='text/javascript'>$(document).ready(\n";
		}

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let args[0] = trim(args[0], "\"");
			if (substr(args[0], 0, 1) != "$") {
				let args[0] = "\"#" . args[0] . "\"";
			} else {
				let args[0] = "\"#<?= " . args[0] . "; ?>\"";
			}

			let output .= "$(" . args[0] . ").get(0).play();";
		}

		if (!in_javascript) {
			let output .= ");</script>";
		}

		return output;
	}
}
