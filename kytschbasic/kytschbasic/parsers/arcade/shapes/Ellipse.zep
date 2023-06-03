/**
 * ELLIPSE parser
 *
 * @package     KytschBASIC\Parsers\Arcade\Shapes\Ellipse
 * @author 		Mike Welsh
 * @copyright   2022 Mike Welsh
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
namespace KytschBASIC\Parsers\Arcade\Shapes;

use KytschBASIC\Parsers\Arcade\Shapes\Shape;
use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Session;

class Ellipse extends Shape
{
	public function build()
	{
		var args, controller;
		let controller = new Args();
		let args = controller->parseShort("ELLIPSE", this->command);

		if (isset(args[0])) {
			let this->x = intval(args[0]);
		}

		if (isset(args[1])) {
			let this->y = intval(args[1]);
		}

		if (isset(args[2])) {
			let this->width = intval(args[2]);
		}

		if (isset(args[3])) {
			let this->height = intval(args[3]);
		}

		let this->colour = this->genColour();
	}

	public function draw()
	{
		return this->colour . "<?php imageellipse($KBIMAGE, " . this->x . "," . this->y . "," . this->width . "," . this->height . ", $KBCOLOUR);?>";
	}
}
