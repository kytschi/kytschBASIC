/**
 * Shape parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Shapes\Shape
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.2
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

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Shape extends Command
{
	public function parse(string line, string command, array args)
	{
		switch (command) {
			case "COPYSHAPE":
				return this->parseCopy(args);
			case "DRAWSHAPE":
				return true;
			case "MOVESHAPE":
				return this->parseMove(args);
			default:
				return null;
		}
	}

	private function parseCopy(array args)
	{
		return "<?php $KBSHAPES[] = $KBSHAPES[count($KBSHAPES) - 1]; ?>";
	}

	private function parseMove(array args)
	{
		return "<?php
		$KBSHAPES[count($KBSHAPES) - 1]['x']=" . intval(isset(args[0]) ? args[0] : 0) . ";
		$KBSHAPES[count($KBSHAPES) - 1]['y']=" . intval(isset(args[1]) ? args[1] : 0) . ";
		?>";
	}
}
