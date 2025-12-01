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

	public function parse(string line, string command, array args, bool in_javascript = false, bool in_event = false)
	{
		switch (command) {
			case "BITMAP":
				return this->processBitmap(args);
			case "BITMAPFONT":
				return this->processBitmapFont(args);
			case "BITMAPTEXT":
				return this->processBitmapText(args);
			case "END BITMAP":
				return this->processEndBitmap(args);
			default:
				return null;
		}
	}

	private function processBitmap(array args)
	{
		var x=0, y=0, width=320, height=240, id;

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let x = "intval(\"" . args[0] . "\")";
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let y = "intval(\"" . args[1] . "\")";
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let width = "intval(\"" . args[2] . "\")";
		}

		if (isset(args[3]) && !empty(args[3]) && args[3] != "\"\"") {
			let height = "intval(\"" . args[3] . "\")";
		}

		if (isset(args[4]) && !empty(args[4]) && args[4] != "\"\"") {
			let id = trim(args[4], "\"");
		} else {
			let id = "KB_BITMAP_" . rand(10000, getrandmax());
		}

		return "<?php 
		$KBSHAPES = [];
		$KBBITMAPID = '" . id . "';
		$KBBITMAPWIDTH = " . width . ";
		$KBBITMAPHEIGHT = " . height . ";
		$KBBITMAPX = " . x . ";
		$KBBITMAPY = " . y . ";
		$KBBITMAP = imagecreatetruecolor($KBBITMAPWIDTH, $KBBITMAPHEIGHT);
		imagealphablending($KBBITMAP, true);
		imageantialias($KBBITMAP, false);
		$KBBKGRND = imagecolorallocatealpha($KBBITMAP, $KBRGB[0], $KBRGB[1], $KBRGB[2], $KBRGB[3]);
		imagefill($KBBITMAP, $KBBITMAPX, $KBBITMAPY, $KBBKGRND);
		?>";
	}

	private function processBitmapFont(array args)
	{
		return "<?php $KBBITMAPFONT=" . args[0] . ";?>";
	}

	private function processBitmapText(array args)
	{
		var output = "<?php ", value;

		let output .= "$KBCOLOUR = imagecolorallocatealpha($KBBITMAP, $KBRGB[0], $KBRGB[1], $KBRGB[2], $KBRGB[3]);";
		let output .= "imagefttext($KBBITMAP, ";

		let value = args[0];

		if (isset(args[1])) {
			let output .= args[1] . ", ";
		} else {
			let output .= "12, ";
		}

		if (isset(args[2])) {
			let output .= args[2] . ", ";
		} else {
			let output .= "0, ";
		}

		if (isset(args[3])) {
			let output .= args[3] . ", ";
		} else {
			let output .= "0, ";
		}

		if (isset(args[4])) {
			let output .= args[4] . ", ";
		} else {
			let output .= "0, ";
		}

		let output .= "$KBCOLOUR, $KBBITMAPFONT, ";

		return output . value . "); ?>";
	}

	private function processEndBitmap(array args)
	{
		return "<?php
			foreach ($KBSHAPES as $KBSHAPE) {
				switch($KBSHAPE['shape']) {
					case 'imagearc':
						$KBCOLOUR = imagecolorallocatealpha($KBBITMAP, $KBSHAPE['colour'][0], $KBSHAPE['colour'][1], $KBSHAPE['colour'][2], $KBSHAPE['colour'][3]);
						imagearc($KBBITMAP, $KBSHAPE['x'], $KBSHAPE['y'], $KBSHAPE['width'], $KBSHAPE['height'], $KBSHAPE['s_angle'], $KBSHAPE['e_angle'], $KBCOLOUR);
						break;
					case 'imageellipse':
						$KBCOLOUR = imagecolorallocatealpha($KBBITMAP, $KBSHAPE['colour'][0], $KBSHAPE['colour'][1], $KBSHAPE['colour'][2], $KBSHAPE['colour'][3]);
						imageellipse($KBBITMAP, $KBSHAPE['x'], $KBSHAPE['y'], $KBSHAPE['width'], $KBSHAPE['height'], $KBCOLOUR);
						break;
					case 'imagefilledarc':
						$KBCOLOUR = imagecolorallocatealpha($KBBITMAP, $KBSHAPE['colour'][0], $KBSHAPE['colour'][1], $KBSHAPE['colour'][2], $KBSHAPE['colour'][3]);
						imagefilledarc($KBBITMAP, $KBSHAPE['x'], $KBSHAPE['y'], $KBSHAPE['width'], $KBSHAPE['height'], $KBSHAPE['s_angle'], $KBSHAPE['e_angle'], $KBCOLOUR, $KBSHAPE['style']);
						break;
					case 'imagefilledrectangle':
						$KBCOLOUR = imagecolorallocatealpha($KBBITMAP, $KBSHAPE['colour'][0], $KBSHAPE['colour'][1], $KBSHAPE['colour'][2], $KBSHAPE['colour'][3]);
						imagefilledrectangle($KBBITMAP, $KBSHAPE['x1'], $KBSHAPE['y1'], $KBSHAPE['x2'], $KBSHAPE['y2'], $KBCOLOUR);
						break;
					case 'imagefilledellipse':
						$KBCOLOUR = imagecolorallocatealpha($KBBITMAP, $KBSHAPE['colour'][0], $KBSHAPE['colour'][1], $KBSHAPE['colour'][2], $KBSHAPE['colour'][3]);
						imagefilledellipse($KBBITMAP, $KBSHAPE['x'], $KBSHAPE['y'], $KBSHAPE['width'], $KBSHAPE['height'], $KBCOLOUR);
						break;
					case 'imageline':
						$KBCOLOUR = imagecolorallocatealpha($KBBITMAP, $KBSHAPE['colour'][0], $KBSHAPE['colour'][1], $KBSHAPE['colour'][2], $KBSHAPE['colour'][3]);
						imageline($KBBITMAP, $KBSHAPE['x1'], $KBSHAPE['y1'], $KBSHAPE['x2'], $KBSHAPE['y2'], $KBCOLOUR);
						break;
					case 'imagerectangle':
						$KBCOLOUR = imagecolorallocatealpha($KBBITMAP, $KBSHAPE['colour'][0], $KBSHAPE['colour'][1], $KBSHAPE['colour'][2], $KBSHAPE['colour'][3]);
						imagerectangle($KBBITMAP, $KBSHAPE['x1'], $KBSHAPE['y1'], $KBSHAPE['x2'], $KBSHAPE['y2'], $KBCOLOUR);
						break;
				}
			}
			ob_start();
			imagepng($KBBITMAP);
			$KBBITMAP = ob_get_contents();
			ob_end_clean(); ?>
			<img id=\"<?= $KBBITMAPID; ?>\" src=\"data:image/png;base64,<?= base64_encode($KBBITMAP); ?>\">";
	}
}
