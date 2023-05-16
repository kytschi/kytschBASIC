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
	private image = null;
	private shape = null;

	public function parse(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		var controller;
		if (this->match(command, "BITMAPTEXT")) {
			let controller = new BitmapText();
			return controller->draw(command, event_manager, globals, config);
		} elseif (this->match(command, "BITMAPFONT")) {
			let controller = new BitmapFont();
			return controller->parse(command, event_manager, globals, config);
		} elseif (this->match(command, "BITMAP CLOSE")) {
			return "<?php ob_start();imagepng($KBIMAGE);$img = ob_get_contents();ob_end_clean(); ?><img src=\"data:image/png;base64,<?= base64_encode($img); ?>\">";
		} elseif (this->match(command, "BITMAP")) {
			var args, x=0, y=0, width=320, height=240, transparency=100;
			let controller = new Args();
			let args = controller->parseShort("BITMAP", command);

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
			let controller = new Rgb();
			let output = controller->code();
			let output = output . "<?php $KBIMAGE = imagecreatetruecolor(" . width . "," .  height . ");imagealphablending($KBIMAGE, true);imageantialias($KBIMAGE, false);";
			let output = output . "$background = imagecolorallocatealpha($KBIMAGE, $red, $green, $blue," . transparency . ");";
			return output . "imagefill($KBIMAGE, " . x . "," . y . ", $background);?>";
		} elseif (this->match(command, "LINE")) {
			let controller = new Line();
			return controller->draw(command, event_manager, globals, config);
		} elseif (this->match(command, "BOXF")) {
			let controller = new Boxf();
			return controller->draw(command, event_manager, globals, config);
		} elseif (this->match(command, "BOX")) {
			let controller = new Box();
			let this->image = controller->draw(command, this->image, event_manager, globals);
			return "";
		} elseif (this->match(command, "ELLIPSEF")) {
			let controller = new Ellipsef();
			return controller->draw(command, event_manager, globals, config);
		} elseif (this->match(command, "ELLIPSE")) {
			let controller = new Ellipse();
			return controller->draw(command, event_manager, globals, config);
		} elseif (this->match(command, "CIRCLEF")) {
			let controller = new Circlef();
			return controller->draw(command, event_manager, globals, config);
		} elseif (this->match(command, "CIRCLE")) {
			let controller = new Circle();
			return controller->draw(command, event_manager, globals, config);
		} elseif (this->match(command, "COPY SHAPE")) {
			let controller = new Session();
			let this->shape = controller->getLastCreate();
			return "";
		} elseif (this->match(command, "DRAW SHAPE")) {
			let this->image = this->shape->copyShape(this->image);
			return "";
		} elseif (this->match(command, "MOVE SHAPE")) {
			let controller = new Args();
			this->shape->move(controller->parseShort("MOVE SHAPE", command), event_manager, globals);
			return "";
		} elseif (this->match(command, "ARCF")) {
			let controller = new Arcf();
			return controller->draw(command, event_manager, globals, config);
		} elseif (this->match(command, "ARC")) {
			let controller = new Arc();
			return controller->draw(command, event_manager, globals, config);
		} elseif (this->match(command, "SET TRANSPARENCY")) {
			let controller = new Args();
			this->shape->setTransparency(controller->parseShort("SET TRANSPARENCY", command), event_manager, globals);
			return "";
		}

		let controller = new Color();

		return controller->parse(
			command,			
			event_manager,
			globals,
			config
		);
	}
}
