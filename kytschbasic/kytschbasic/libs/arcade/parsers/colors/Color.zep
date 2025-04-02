/**
 * COLOR parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Colors\Color
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2022 Mike Welsh
 * @link 		https://kytschbasic.org
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
namespace KytschBASIC\Libs\Arcade\Parsers\Colors;

use KytschBASIC\Parsers\Core\Command;

class Color extends Command
{
	public function parse(string line, string command, array args)
	{
		if (command == "RGB") {
			return this->parseRgb(args);
		}

		return null;
	}

	public function parseRgb(args)
	{
		var output = "<?php $KBRGB=[";
		let args = this->args(args);
				
		if (isset(args[0])) {
			let output .= intval(args[0]) . ",";
		} else {
			let output .= "0,";
		}

		if (isset(args[1])) {
			let output .= intval(args[1]) . ",";
		} else {
			let output .= "0,";
		}

		if (isset(args[2])) {
			let output .= intval(args[2]) . ",";
		} else {
			let output .= "0,";
		}

		if (isset(args[3])) {
			let output .= intval(args[3]) . ",";
		} else {
			let output .= "100,";
		}

		return rtrim(output, ",") . "];?>";
	}
}
