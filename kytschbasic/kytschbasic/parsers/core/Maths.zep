/**
 * Maths parser
 *
 * @package     KytschBASIC\Parsers\Core\Maths
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

use KytschBASIC\Parsers\Core\Variables;

class Maths extends Variables
{
	private bracket_checks = ["%)", "$)", "#)", "&)"];

	public function equation(command)
	{
		if (substr(command, 0, 1) == "\"" || command == "" || command === null) {
			return command;
		}

		var splits, val, cleaned, check;
		
		let splits = preg_split("/\*|\+|\<-|\-|\>=|\>|\<=|\<|\==|\//", command, 0, 2);
				
		if (count(splits) == 1) {
			return command;
		}
		
		for val in splits {			
			if (!is_numeric(val)) {
				if (in_array(substr(val, strlen(val) - 2, 2), this->bracket_checks)) {
					let val = rtrim(val, ")");
				}

				if (in_array(substr(val, strlen(val) - 1, 1), this->types)) {
					let cleaned = str_replace(this->types, "", val);
					let command = str_replace(val, "$" . cleaned, command);
				} else {
					for check in this->array_types {
						if (strpos(val, check) !== false) {
							let cleaned = str_replace(this->array_types, "[", val);
							if (substr(cleaned, "))") !== false) {
								let cleaned = rtrim(cleaned, "))") . "])";
							} else {
								let cleaned = rtrim(cleaned, ")") . "]";
							}
							let command = str_replace(val, "$" . cleaned, command);
							break;
						}
					}
				}
			}
		}

		return command;
	}

	public function parse(string command, string args)
	{
		if (substr(command, 0, 1) == "\"") {
			return null;
		}

		var splits = [];
		
		let splits = explode(" ", command);
		
		let command = (string)splits[0];
		array_shift(splits);

		let splits = implode(" ", splits);
		
		if (command == "ABS") {
			return abs(splits);
		} elseif (command == "ACOS") {
			return acos(floatval(splits));
		} elseif (command == "ASIN") {
			return asin(floatval(splits));
		} elseif (command == "ATAN") {
			return atan(floatval(splits));
		} elseif (command == "HCOS") {
			return cosh(floatval(splits));
		} elseif (command == "HSIN") {
			return sinh(floatval(splits));
		} elseif (command == "HTAN") {
			return tanh(floatval(splits));
		} elseif (command == "COS") {
			return cos(floatval(splits));
		} elseif (command == "SIN") {
			return sin(floatval(splits));
		} elseif (command == "TAN") {
			return tan(floatval(splits));
		} elseif (command == "EXP") {
			return exp(floatval(splits));
		} elseif (command == "SQR") {
			return sqrt(floatval(splits));
		} elseif (command == "LOG") {
			let splits = explode(",", splits);
			if (count(splits) > 1) {
				return log(floatval(splits[0]), floatval(splits[1]));
			} else {
				return log(floatval(splits[0]));
			}
		} elseif (command == "LOG10") {
			return log10(splits);
		} elseif (command == "HEX") {
			return "\"" . str_pad(dechex(intval(splits)), 8, "0", 0) . "\"";
		} elseif (command == "BIN") {
			return "\"" . str_pad(decbin(intval(splits)), 32, "0", 0) . "\"";
		} elseif (command == "FRAC") {
			return fmod(splits, 1);
		} elseif (command == "RND") {
			if (empty(splits)) {
				return rand(1, 10) / 10;
			} else {
				let splits = explode(",", splits);
				if (count(splits) == 1) {
					return rand(1, intval(splits[0]));
				} else {
					return rand(intval(splits[0]), intval(splits[1]));
				}
			}
		} elseif (command == "SGN") {
			let splits = intval(splits);
			if (splits > 0) {
				return 1;
			} elseif (splits < 0) {
				return -1;
			} else {
				return 0;
			}
		}

		return null;
	}
}
