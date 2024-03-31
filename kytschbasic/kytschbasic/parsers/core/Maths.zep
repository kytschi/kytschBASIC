/**
 * Maths parser
 *
 * @package     KytschBASIC\Parsers\Core\Maths
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2024 Mike Welsh
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
namespace KytschBASIC\Parsers\Core;

class Maths
{
	public static function equation(string command)
	{
		var splits, val;
		
		let splits = preg_split("/\*|\+|\-|\//", command, 0, 2);

		if (count(splits) == 1) {
			return command;
		}

		for val in splits {
			if (!is_numeric(val) && substr(val, 0, 1) != "$") {
				let command = str_replace(val, "$" . val, command);
			}
		}

		return command;
	}

	public static function parse(command)
	{
		if (substr(command, 0, 1) == "\"") {
			return null;
		}

		var args;
		let args = explode(" ", command);

		let command = args[0];
		array_shift(args);
		let args = implode(" ", args);
		
		if (command == "ABS") {
			return abs(args);
		} elseif (command == "ACOS") {
			return acos(floatval(args));
		} elseif (command == "ASIN") {
			return asin(floatval(args));
		} elseif (command == "ATAN") {
			return atan(floatval(args));
		} elseif (command == "HCOS") {
			return cosh(floatval(args));
		} elseif (command == "HSIN") {
			return sinh(floatval(args));
		} elseif (command == "HTAN") {
			return tanh(floatval(args));
		} elseif (command == "COS") {
			return cos(floatval(args));
		} elseif (command == "SIN") {
			return sin(floatval(args));
		} elseif (command == "TAN") {
			return tan(floatval(args));
		} elseif (command == "EXP") {
			return exp(floatval(args));
		} elseif (command == "SQR") {
			return sqrt(floatval(args));
		} elseif (command == "LOG") {
			let args = explode(";", args);
			if (count(args) > 1) {
				return log(floatval(args[0]), floatval(args[1]));
			} else {
				return log(floatval(args[0]));
			}
		} elseif (command == "LOG10") {
			return log10(args);
		} elseif (command == "HEX") {
			return "\"" . str_pad(dechex(intval(args)), 8, "0", 0) . "\"";
		} elseif (command == "BIN") {
			return "\"" . str_pad(decbin(intval(args)), 32, "0", 0) . "\"";
		} elseif (command == "FRAC") {
			return fmod(args, 1);
		} elseif (command == "RND") {
			if (empty(args)) {
				return rand(1, 10) / 10;
			} else {
				let args = explode(";", args);
				if (count(args) == 1) {
					return rand(1, intval(args[0]));
				} else {
					return rand(intval(args[0]), intval(args[1]));
				}
			}
		} elseif (command == "SGN") {
			let args = intval(args);
			if (args > 0) {
				return 1;
			} elseif (args < 0) {
				return -1;
			} else {
				return 0;
			}
		} 

		return null;
	}
}
