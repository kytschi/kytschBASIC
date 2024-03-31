/**
 * BITMAP parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Bitmap
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
namespace KytschBASIC\Libs\Arcade\Parsers;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Bitmap extends Command
{
	private image = null;
	private copy = null;

	public function parse(string command, string args)
	{
		if (command == "BITMAP") {
			return this->parseBitmap(args);
		} elseif (command == "BITMAP CLOSE") {
			return "<?php ob_start();imagepng($KBIMAGE);$img = ob_get_contents();ob_end_clean(); ?><img src=\"data:image/png;base64,<?= base64_encode($img); ?>\">";
		}

		/*var controller;
		if (this->match(command, "BITMAPTEXT")) {
			let controller = new BitmapText(command, event_manager, globals, config);
			return controller->draw();
		} elseif (this->match(command, "BITMAPFONT")) {
			let controller = new BitmapFont();
			return controller->parse(command, event_manager, globals, config);
		} elseif (this->match(command, "BITMAP CLOSE")) {
			return "<?php ob_start();imagepng($KBIMAGE);$img = ob_get_contents();ob_end_clean(); ?><img src=\"data:image/png;base64,<?= base64_encode($img); ?>\">";
		} elseif (this->match(command, "LINE")) {
			let controller = new Line(command, event_manager, globals, config);
			return controller->draw();
		} elseif (this->match(command, "BOXF")) {
			let controller = new Boxf(command, event_manager, globals, config);
			return controller->draw();
		} elseif (this->match(command, "BOX")) {
			let controller = new Box(command, this->image, event_manager, globals);
			let this->image = controller->draw();
			return "";
		} elseif (this->match(command, "ELLIPSEF")) {
			let controller = new Ellipsef(command, event_manager, globals, config);
			return controller->draw();
		} elseif (this->match(command, "ELLIPSE")) {
			let controller = new Ellipse(command, event_manager, globals, config);
			return controller->draw();
		} elseif (this->match(command, "CIRCLEF")) {
			let controller = new Circlef(command, event_manager, globals, config);
			return controller->draw();
		} elseif (this->match(command, "CIRCLE")) {
			let this->image = new Circle(command, event_manager, globals, config);
			return this->image->draw();
		} elseif (this->match(command, "COPY SHAPE")) {
			//let this->copy = clone this->image;
			return "";
		} elseif (this->match(command, "DRAW SHAPE")) {
			return this->image->draw();
		} elseif (this->match(command, "MOVE SHAPE")) {
			this->image->move(command);
			return "";
		} elseif (this->match(command, "ARCF")) {
			let controller = new Arcf(command, event_manager, globals, config);
			return controller->draw();
		} elseif (this->match(command, "ARC")) {
			let controller = new Arc(command, event_manager, globals, config);
			return controller->draw();
		} elseif (this->match(command, "SET TRANSPARENCY")) {
			this->image->setTransparency(command);
			return "";
		}

		let controller = new Color();

		return controller->parse(
			command,			
			event_manager,
			globals,
			config
		);*/
	}

	private function parseBitmap(args)
	{
		var x=0, y=0, width=320, height=240, output = "";
		let args = this->args(args);

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

		let output = "<?php $KBIMAGE = imagecreatetruecolor(" . width . "," .  height . ");";
		let output .= "imagealphablending($KBIMAGE, true);imageantialias($KBIMAGE, false);";
		let output .= "$KBBKGRND = imagecolorallocatealpha($KBIMAGE, $KBRGB[0], $KBRGB[1], $KBRGB[2], $KBRGB[3]);";
		return output . "imagefill($KBIMAGE, " . x . "," . y . ", $KBBKGRND);?>";
	}
}
