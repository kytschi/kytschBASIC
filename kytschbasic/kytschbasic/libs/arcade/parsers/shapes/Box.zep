/**
 * BOX parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Shapes\Box
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
namespace KytschBASIC\Libs\Arcade\Parsers\Shapes;

use KytschBASIC\Parsers\Core\Command;

class Box extends Command
{
	public function parse(string command, string args)
	{
		if (command == "BOX") {
			return this->parseBox(args);
		} elseif (command == "BOXF") {
			return this->parseBox(args, true);
		}
	}

	public function parseBox(args, bool fill = false)
	{
		var output = "<?php ";
		let args = this->args(args);

		let output .= "$KBCOLOUR = imagecolorallocatealpha($KBIMAGE, $KBRGB[0], $KBRGB[1], $KBRGB[2], $KBRGB[3]);";
		let output .= (fill ? "imagefilledrectangle" : "imagerectangle") . "($KBIMAGE, ";

		if (isset(args[0])) {
			let output .= args[0] . ", ";
		} else {
			let output .= "0, ";
		}

		if (isset(args[1])) {
			let output .= args[1] . ", ";
		} else {
			let output .= "0, ";
		}

		if (isset(args[2])) {
			let output .= args[2] . ", ";
		} else {
			let output .= "50, ";
		}

		if (isset(args[3])) {
			let output .= args[3] . ", ";
		} else {
			let output .= "50, ";
		}

		return output . "$KBCOLOUR);?>";
	}
}
