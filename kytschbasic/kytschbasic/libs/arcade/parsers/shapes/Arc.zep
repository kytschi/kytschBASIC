/**
 * ARC parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Shapes\Arc
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.3
 *
 * Copyright 2025 Mike Welsh
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
namespace KytschBASIC\Libs\Arcade\Parsers\Shapes;

use KytschBASIC\Parsers\Core\Command;

class Arc extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, bool in_event = false)
	{
		switch (command) {
			case "ARC":
				return this->parseArc(args);
			case "ARCF":
				return this->parseArc(args, true);
			default:
				return null;
		}
	}

	public function parseArc(array args, bool filled = false)
	{
		return "<?php $KBSHAPES[] = [
			'colour' => $KBRGB,
			'shape' => '" . (filled ? "imagefilledarc" : "imagearc") . "',
			'x' => " . (isset(args[0]) ? intval(args[0]) : 0) . ",
			'y' => " . (isset(args[1]) ? intval(args[1]) : 0) . ",
			's_angle' => " . (isset(args[2]) ? intval(args[2]) : 0) . ",
			'e_angle' => " . (isset(args[3]) ? intval(args[3]) : 0) . ",
			'width' => " . (isset(args[4]) ? intval(args[4]) : 10) . ",
			'height' => " . (isset(args[4]) ? intval(args[4]) : 10) . ",
			'style' => " . (isset(args[5]) ? args[5] : "IMG_ARC_NOFILL") . ",
		]; ?>";
	}
}
