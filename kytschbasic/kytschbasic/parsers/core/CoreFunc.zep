/**
 * FUNCTION parser
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
namespace KytschBASIC\Parsers\Core;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class CoreFunc extends Command
{
	public function parse(string line, string command, array args)
	{
		switch(command) {
			case "FUNCTION":
				return this->parseFunction(line, args);
			default:
				return null;
		}
	}

	private function parseFunction(string line, array args)
	{
		var output = "<?php function ", key, str, splits, arg, args;

		if (empty(args) || args[0] == "\"\"") {
			throw new Exception("Invalid FUNCTION");
		}

		let args[0] = trim(args[0], "\"") . "(";

		let output .= args[0];
		array_shift(args);

		for arg in args {
			let splits = preg_split("/=\\$(?=(?:[^\"']*[\"'][^\"']*[\"'])*[^\"']*$)/", arg, -1, PREG_SPLIT_NO_EMPTY | PREG_SPLIT_DELIM_CAPTURE);
			if (count(splits) > 1) {
				for key, str in splits {
					if (!key) {
						let output .= str . "=";
					} else {
						let output .= "'$" . str . "";
					}
				}
			} else {
				let output .= "$" . str_replace(this->types, "", arg);
			}

			let output .= ", ";
		}

		return rtrim(output, ", ") . ") {\n ?>";
	}
}
