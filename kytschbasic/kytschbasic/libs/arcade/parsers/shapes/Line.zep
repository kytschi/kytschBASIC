/**
 * LINE parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Shapes\Line
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
namespace KytschBASIC\Libs\Arcade\Parsers\Shapes;

use KytschBASIC\Parsers\Core\Command;

class Line extends Command
{
	public function parse(string command, string args)
	{
		if (command == "LINE") {
			return this->parseLine(args);
		}
	}

	public function parseLine(args)
	{
		let args = this->args(args);

		return "<?php $KBSHAPES[] = [
			'colour' => $KBRGB,
			'shape' => 'imageline',
			'x1' => " . (isset(args[0]) ? intval(args[0]) : 0) . ",
			'y1' => " . (isset(args[1]) ? intval(args[1]) : 0) . ",
			'x2' => " . (isset(args[2]) ? intval(args[2]) : 20) . ",
			'y2' => " . (isset(args[3]) ? intval(args[3]) : 20) . ",
		]; ?>";
	}
}
