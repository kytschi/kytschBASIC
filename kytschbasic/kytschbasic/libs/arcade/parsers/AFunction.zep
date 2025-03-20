/**
 * AFUNCTION parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Function
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.1
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
namespace KytschBASIC\Libs\Arcade\Parsers;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class AFunction extends Command
{
	public function parse(string command, string args)
	{
		if (command == "AFUNCTION") {
			return this->parseFunction(args);
		} elseif (command == "END AFUNCTION") {
			return "\n});</script>";
		}
	}

	private function parseFunction(args)
	{
		var output="<script type='text/javascript'>$(function() {\n", splits;
		let args = this->args(args);

		if (isset(args[0])) {
			preg_match_all("/(.*?)(\(.*?\))/", args[0], splits);
			if (!empty(splits[1]) && !empty(splits[2])) {
				let args[0] = array_shift(splits[2]);

				let output .= "function " .
					array_shift(splits[1]) .
					this->clean(
						args[0],
						false, 
						in_array(substr(args[0], strlen(args[0]) - 1, 1), this->types) ? true : false
					) .
					"{";
			} else {
				throw new Exception("Invalid AFUNCTION");
			}
		}

		return output . "\n}";
	}
}
