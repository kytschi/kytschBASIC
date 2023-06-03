/**
 * LINE parser
 *
 * @package     KytschBASIC\Parsers\Arcade\Shapes\Line
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

use KytschBASIC\Parsers\Arcade\Colors\Rgb;
use KytschBASIC\Parsers\Arcade\Shapes\Shape;
use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Session;

class Line extends Shape
{
	protected x1=0;
	protected y1=0;
	protected x2=0;
	protected y2=0;

	public function build()
	{
		var args, controller;
		let controller = new Args();
		let args = controller->parseShort("LINE", this->command);

		if (isset(args[0])) {
			let this->x1 = intval(args[0]);
		}

		if (isset(args[1])) {
			let this->y1 = intval(args[1]);
		}

		if (isset(args[2])) {
			let this->x2 = intval(args[2]);
		}

		if (isset(args[3])) {
			let this->y2 = intval(args[3]);
		}

		let this->colour = this->genColour();
	}

	public function copyShape(
		var image
	) {
		var colour = imagecolorallocatealpha(image, this->red, this->green, this->blue, this->transparency);
		imageline(image, this->x1, this->y1, this->x2, this->y2, colour);

		return image;
	}

	public function draw()
	{
		return this->colour . "<?php imageline($KBIMAGE, " . this->x1 . "," . this->y1 . "," . this->x2 . "," . this->y2 . ", $KBCOLOUR);?>";
	}

	public function getX1()
	{
		return this->x1;
	}

	public function getX2()
	{
		return this->x2;
	}

	public function getY1()
	{
		return this->y1;
	}

	public function getY2()
	{
		return this->y2;
	}
}
