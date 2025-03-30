/**
 * AFUNCTION parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\AFunction
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
			return "}\n</script>\n";
		}
	}

	private function parseFunction(args)
	{
		var output = "<script type=\"text/javascript\">\n", splits, str;

		preg_match_all("/\((.*?)\)/", args, splits);
		
		if (!empty(splits[0])) {
			let str = str_replace(array_shift(splits[0]), "", args);
			let output .= "function " . str . "(event, ";

			let args = this->args(array_shift(splits[1]));
			let output .= implode(", ", args) . ") {\n";
		} else {
			throw new Exception("Invalid AFUNCTION");
		}

		return output;
	}
}
