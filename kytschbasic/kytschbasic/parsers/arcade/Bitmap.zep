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
use KytschBASIC\Parsers\Arcade\Colors\Rgb;
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
		if (self::match(command, "BITMAPTEXT")) {
			return BitmapText::draw(command, event_manager, globals, config);
		} elseif (self::match(command, "BITMAPFONT")) {
			return BitmapFont::parse(command, event_manager, globals, config);
		} elseif (self::match(command, "BITMAP CLOSE")) {
			return "<?php ob_start();imagepng($KBIMAGE);$img = ob_get_contents();ob_end_clean(); ?><img src=\"data:image/png;base64,<?= base64_encode($img); ?>\">";
		} elseif (self::match(command, "BITMAP")) {
			var args, x=0, y=0, width=320, height=240, transparency=100;
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

			var output;
			let output = Rgb::code();
			let output = output . "<?php $KBIMAGE = imagecreatetruecolor(" . width . "," .  height . ");imagealphablending($KBIMAGE, true);imageantialias($KBIMAGE, false);";
			let output = output . "$background = imagecolorallocatealpha($KBIMAGE, $red, $green, $blue," . transparency . ");";
			return output . "imagefill($KBIMAGE, " . x . "," . y . ", $background);?>";
		} elseif (self::match(command, "LINE")) {
			return Line::draw(command, event_manager, globals, config);
		} elseif (self::match(command, "BOXF")) {
			return Boxf::draw(command, event_manager, globals, config);
		} elseif (self::match(command, "BOX")) {
			let self::image = Box::draw(command, self::image, event_manager, globals);
			return "";
		} elseif (self::match(command, "ELLIPSEF")) {
			return Ellipsef::draw(command, event_manager, globals, config);
		} elseif (self::match(command, "ELLIPSE")) {
			return Ellipse::draw(command, event_manager, globals, config);
		} elseif (self::match(command, "CIRCLEF")) {
			return Circlef::draw(command, event_manager, globals, config);
		} elseif (self::match(command, "CIRCLE")) {
			return Circle::draw(command, event_manager, globals, config);
		} elseif (self::match(command, "COPY SHAPE")) {
			let self::shape = Session::getLastCreate();
			return "";
		} elseif (self::match(command, "DRAW SHAPE")) {
			let self::image = self::shape->copyShape(self::image);
			return "";
		} elseif (self::match(command, "MOVE SHAPE")) {
			self::shape->move(Args::parseShort("MOVE SHAPE", command), event_manager, globals);
			return "";
		} elseif (self::match(command, "ARCF")) {
			return Arcf::draw(command, event_manager, globals, config);
		} elseif (self::match(command, "ARC")) {
			return Arc::draw(command, event_manager, globals, config);
		} elseif (self::match(command, "SET TRANSPARENCY")) {
			self::shape->setTransparency(Args::parseShort("SET TRANSPARENCY", command), event_manager, globals);
			return "";
		}

		return Color::parse(
			command,			
			event_manager,
			globals,
			config
		);
	}
}
