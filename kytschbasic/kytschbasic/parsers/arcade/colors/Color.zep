/**
 * COLOR parser
 *
 * @package     KytschBASIC\Parsers\Arcade\Colors\Color
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
namespace KytschBASIC\Parsers\Arcade\Colors;

use KytschBASIC\Parsers\Arcade\Colors\Rgb;
use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Session;

class Color extends Command
{
	public function parse(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (this->match(command, "RGB")) {
			var rgb;
			let rgb = new Rgb();
			return rgb->parse(command, event_manager, globals);
		}

		return null;
	}
}
