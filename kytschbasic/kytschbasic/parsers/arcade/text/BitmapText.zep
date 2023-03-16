/**
 * BITMAP parser
 *
 * @package     KytschBASIC\Parsers\Arcade\Text\BitmapText
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
namespace KytschBASIC\Parsers\Arcade\Text;

use KytschBASIC\Parsers\Arcade\Shapes\Shape;
use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Session;

class BitmapText extends Shape
{
	protected static size;

	public static function draw(
		string command,
		var image,
		event_manager = null,
		array globals = []
	) {
		var args, rgb, colour, font, text;
		let args = Args::parseShort("BITMAPTEXT", command);

		if (isset(args[0])) {
			let self::x = intval(args[0]);
		}

		if (isset(args[1])) {
			let self::y = intval(args[1]);
		}

		if (isset(args[2])) {
			let self::size = intval(args[2]);
		}

		if (isset(args[3])) {
			let self::start_angle = intval(args[3]);
		}

		if (isset(args[4])) {
			if (intval(args[4])) {
				let self::transparency = Args::transparency(args[4]);
			} else {
				let text = trim(args[4], "\"");
			}
		}

		if (count(args) > 6) {
			let args = array_slice(args, 5, count(args) - 5);
			let text = trim(implode(",", args), "\"");
		} elseif (isset(args[5])) {
			let text = trim(args[5], "\"");
		}

		let rgb = Session::read("RGB#");
		if (rgb) {
			let self::red = intval(rgb[0]);
			let self::green = intval(rgb[1]);
			let self::blue = intval(rgb[2]);
		}

		let font = Session::read("BITMAPFONT#");
		if (empty(font)) {
			throw new \Exception("No BITMAPFONT defined");
		}
		
		let font = Args::processGlobals(font, globals);

		let colour = imagecolorallocatealpha(image, self::red, self::green, self::blue, self::transparency);
		imagefttext(image, self::size, self::start_angle, self::x, self::y, colour, font, text);

		Session::addLastCreate(new self());

		return image;
	}
}
