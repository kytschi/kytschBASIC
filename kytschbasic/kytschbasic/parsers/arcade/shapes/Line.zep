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

use KytschBASIC\Parsers\Arcade\Shapes\Shape;
use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Session;

class Line extends Shape
{
	protected static x1=0;
	protected static y1=0;
	protected static x2=0;
	protected static y2=0;

	public function copyShape(
		var image
	) {
		var colour = imagecolorallocatealpha(image, self::red, self::green, self::blue, self::transparency);
		imageline(image, self::x1, self::y1, self::x2, self::y2, colour);

		return image;
	}

	public static function draw(
		string command,
		var image,
		event_manager = null,
		array globals = []
	) {
		var args, colour, rgb;
		let args = Args::parseShort("LINE", command);

		if (isset(args[0])) {
			let self::x1 = intval(args[0]);
		}

		if (isset(args[1])) {
			let self::y1 = intval(args[1]);
		}

		if (isset(args[2])) {
			let self::x2 = intval(args[2]);
		}

		if (isset(args[3])) {
			let self::y2 = intval(args[3]);
		}

		let rgb = Session::read("RGB#");

		if (rgb) {
			let self::red = intval(rgb[0]);
			let self::green = intval(rgb[1]);
			let self::blue = intval(rgb[2]);
			let self::transparency = Args::transparency(rgb[3]);
		}

		let colour = imagecolorallocatealpha(image, self::red, self::green, self::blue, self::transparency);
		imageline(image, self::x1, self::y1, self::x2, self::y2, colour);

		Session::addLastCreate(new self());

		return image;
	}

	public function getX1()
	{
		return self::x1;
	}

	public function getX2()
	{
		return self::x2;
	}

	public function getY1()
	{
		return self::y1;
	}

	public function getY2()
	{
		return self::y2;
	}
}
