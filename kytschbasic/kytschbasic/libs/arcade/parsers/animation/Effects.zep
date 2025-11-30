/**
 * Effects parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Animation\Effects
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
namespace KytschBASIC\Libs\Arcade\Parsers\Animation;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Effects extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false)
	{
		switch (command) {
			case "SPIN":
				return this->processSpin(args, in_javascript);
			default:
				return null;
		}
	}

	public function processSpin(args, bool in_javascript = false)
	{
		var output = "<script type='text/javascript'>$(document).ready(function() {", milliseconds = 500, direction = "clockwise";

		if (in_javascript) {
			let output = "";
		}
		
		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let milliseconds = intval(trim(args[1], "\""));
		}

		if (milliseconds < 0) {
			let milliseconds = 500;
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let direction = strtolower(trim(args[2], "\""));
			if (!in_array(direction, ["clockwise", "anti-clockwise"])) {
				let direction = "clockwise";
			}
		}

		if (direction == "anti-clockwise") {
			let direction = "KBSPINANTI";
		} else {
			let direction = "KBSPIN";
		}

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= "$('#" . trim(args[0], "\"") . "').css('-webkit-animation', '" . direction. " linear " . milliseconds . "ms infinite')";
			let output .= ".css('animation', '" . direction. " linear " . milliseconds . "ms infinite');";
		} else {
			throw new Exception("Invalid SPIN, target not set.");
		}

		return output . (in_javascript ? "" : "});</script>");
	}
}
