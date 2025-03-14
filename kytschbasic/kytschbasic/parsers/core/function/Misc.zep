/**
 * Misc functions parser
 *
 * @package     KytschBASIC\Parsers\Core\Function\Misc
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
namespace KytschBASIC\Parsers\Core\Function;

use KytschBASIC\Parsers\Core\Command;

class Misc extends Command
{
	public function processFunction(args)
	{
		if (is_string(args)) {
			let args = [args];
		}

		if (substr(args[0], 0, 5) == "COUNT") {
			let args[0] = trim(str_replace("COUNT", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid COUNT");
			}

			return "count($" . str_replace(this->types, "", args[0]) . ")";
		} else {
			return this->clean(
				args[0],
				false, 
				in_array(substr(args[0], strlen(args[0]) - 1, 1), this->types) ? true : false
			);
		}
	}
}
