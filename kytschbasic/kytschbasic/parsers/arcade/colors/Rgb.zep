/**
 * RGB parser
 *
 * @package     KytschBASIC\Parsers\Arcade\Colors\Rgb
 * @author 		Mike Welsh
 * @copyright   2023 Mike Welsh
 * @version     0.0.2
 *
 * Copyright 2023 Mike Welsh
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
namespace KytschBASIC\Parsers\Arcade\Colors;

use KytschBASIC\Parsers\Core\Command;

class Rgb extends Command
{
	public function parse(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		var args, red=0, green=0, blue=0, transparency=0;
		let args = this->parseArgs("RGB", command);

		if (isset(args[0])) {
			let red = intval(args[0]);
		}

		if (isset(args[1])) {
			let green = intval(args[1]);
		}

		if (isset(args[2])) {
			let blue = intval(args[2]);
		}

		if (isset(args[3])) {
			let transparency = intval(args[3]);
		}	

		return "<?php $RGB=[" . red . "," . green . "," .  blue . "," . transparency . "];?>";
	}

	public function code()
	{
		return "<?php $red = 0; $green = 0; $blue = 0; if ($RGB) {$red = intval($RGB[0]);$green = intval($RGB[1]);$blue = intval($RGB[2]);}?>";
	}
}
