/**
 * BITMAP parser
 *
 * @package     KytschBASIC\Parsers\Arcade\Bitmap
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
namespace KytschBASIC\Parsers\Arcade;

use KytschBASIC\Parsers\Arcade\Colors\Color;
use KytschBASIC\Parsers\Arcade\Shapes\Arc;
use KytschBASIC\Parsers\Arcade\Shapes\Arcf;
use KytschBASIC\Parsers\Arcade\Shapes\Circle;
use KytschBASIC\Parsers\Arcade\Shapes\Circlef;
use KytschBASIC\Parsers\Arcade\Shapes\Ellipse;
use KytschBASIC\Parsers\Arcade\Shapes\Ellipsef;
use KytschBASIC\Parsers\Arcade\Shapes\Line;
use KytschBASIC\Parsers\Arcade\Shapes\Box;
use KytschBASIC\Parsers\Arcade\Shapes\Boxf;
use KytschBASIC\Parsers\Arcade\Text\BitmapFont;
use KytschBASIC\Parsers\Arcade\Text\BitmapText;
use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Session;

class Bitmap extends Command
{
	private static image = null;
	private static shape = null;

	public static function parse(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (substr(command, 0, 10) == "BITMAPTEXT") {
			let self::image = BitmapText::draw(command, self::image, event_manager, globals);
			return "";
		} elseif (substr(command, 0, 10) == "BITMAPFONT") {
			return BitmapFont::parse(command, event_manager, globals);
		} elseif (substr(command, 0, 12) == "BITMAP CLOSE") {
			var bin;

			ob_start();
			imagepng(self::image);
			let bin = ob_get_clean();
			imagedestroy(self::image);

			let self::image = null;

			return self::output("<img src=\"data:image/png;base64," . base64_encode(bin) . "\">");
		} elseif (substr(command, 0, 6) == "BITMAP") {
			var args, x=0, y=0, width=320, height=240, red=0, green=0, blue=0, transparency=100, rgb;
			let args = Args::parseShort("BITMAP", command);

			if (isset(args[0])) {
				let x = intval(args[0]);
			}

			if (isset(args[1])) {
				let y = intval(args[1]);
			}

			if (isset(args[2])) {
				let width = intval(args[2]);
			}

			if (isset(args[3])) {
				let height = intval(args[3]);
			}

			if (isset(args[4])) {
				let transparency = intval(args[4]);
			}

			let rgb = Session::read("RGB#");

			if (rgb) {
				let red = intval(rgb[0]);
				let green = intval(rgb[1]);
				let blue = intval(rgb[2]);
			}

			let self::image = imagecreatetruecolor(width, height);
			imagealphablending(self::image, true);
			//imagesavealpha(self::image, true);
			imageantialias(self::image, false);

			var background;
			let background = imagecolorallocatealpha(self::image, red, green, blue, transparency);
			imagefill(self::image, x, y, background);

			return "";
		} elseif (substr(command, 0, 4) == "LINE" && self::image != null) {
			let self::image = Line::draw(command, self::image, event_manager, globals);
			return "";
		} elseif (substr(command, 0, 4) == "BOXF" && self::image != null) {
			let self::image = Boxf::draw(command, self::image, event_manager, globals);
			return "";
		} elseif (substr(command, 0, 3) == "BOX" && self::image != null) {
			let self::image = Box::draw(command, self::image, event_manager, globals);
			return "";
		} elseif (substr(command, 0, 8) == "ELLIPSEF" && self::image != null) {
			let self::image = Ellipsef::draw(command, self::image, event_manager, globals);
			return "";
		} elseif (substr(command, 0, 7) == "ELLIPSE" && self::image != null) {
			let self::image = Ellipse::draw(command, self::image, event_manager, globals);
			return "";
		} elseif (substr(command, 0, 7) == "CIRCLEF" && self::image != null) {
			let self::image = Circlef::draw(command, self::image, event_manager, globals);
			return "";
		} elseif (substr(command, 0, 6) == "CIRCLE" && self::image != null) {
			let self::image = Circle::draw(command, self::image, event_manager, globals);
			return "";
		} elseif (substr(command, 0, 10) == "COPY SHAPE" && self::image != null) {
			let self::shape = Session::getLastCreate();
			return "";
		} elseif (substr(command, 0, 10) == "DRAW SHAPE" && self::image != null) {
			let self::image = self::shape->copyShape(self::image);
			return "";
		} elseif (substr(command, 0, 10) == "MOVE SHAPE" && self::image != null) {
			self::shape->move(Args::parseShort("MOVE SHAPE", command), event_manager, globals);
			return "";
		} elseif (substr(command, 0, 4) == "ARCF" && self::image != null) {
			let self::image = Arcf::draw(command, self::image, event_manager, globals);
			return "";
		} elseif (substr(command, 0, 3) == "ARC" && self::image != null) {
			let self::image = Arc::draw(command, self::image, event_manager, globals);
			return "";
		} elseif (substr(command, 0, 16) == "SET TRANSPARENCY" && self::image != null) {
			self::shape->setTransparency(Args::parseShort("SET TRANSPARENCY", command), event_manager, globals);
			return "";
		}

		return Color::parse(
			command,			
			event_manager,
			globals
		);
	}
}
