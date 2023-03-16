/**
 * Maths parser
 *
 * @package     KytschBASIC\Parsers\Core\Maths
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
namespace KytschBASIC\Parsers\Core;

class Maths
{
	public static function commands(
		string command,
		boolean add_qoutes = false
	) {
		var matches, key, found, replace, splits, haystack;

		preg_match_all(
			"/ABS\((.*?)\)|FRAC\((.*?)\)|RND\((.*?)\)|SGN\((.*?)\)|COS\((.*?)\)|SIN\((.*?)\)|TAN\((.*?)\)|ACOS\((.*?)\)|ASIN\((.*?)\)|ATAN\((.*?)\)|HCOS\((.*?)\)|HSIN\((.*?)\)|HTAN\((.*?)\)|EXP\((.*?)\)|SQR\((.*?)\)|LOG\((.*?)\)|LOG10\((.*?)\)|HEX\\$\((.*?)\)|BIN\\$\((.*?)\)/",
			command,
			matches
		);

		if (count(matches[0]) == 0) {
			return command;
		}

		for key, found in matches[0] {
			if (strpos(found, "ABS(") !== false) {
				let replace = abs(matches[1][key]);
			} elseif (strpos(found, "FRAC(") !== false) {
				let replace = fmod(matches[2][key], 1);
			} elseif (strpos(found, "RND(") !== false) {
				if (empty(matches[3][key])) {
					let replace = rand(1, 10) / 10;
				} else {
					let splits = explode(",", matches[3][key]);
					if (count(splits) == 1) {
						let replace = rand(0, intval(splits[0]));
					} else {
						let replace = rand(
							intval(splits[0]),
							intval(splits[1])
						);
					}
				}
			} elseif (strpos(found, "SGN(") !== false) {
				let replace = intval(matches[4][key]);

				if (haystack > 0) {
					let replace = 1;
				} elseif (haystack < 0) {
					let replace = -1;
				}
			} elseif (strpos(found, "ACOS(") !== false) {
				let replace = acos(floatval(matches[8][key]));
			} elseif (strpos(found, "ASIN(") !== false) {
				let replace = asin(floatval(matches[9][key]));
			} elseif (strpos(found, "ATAN(") !== false) {
				let replace = atan(floatval(matches[10][key]));
			} elseif (strpos(found, "HCOS(") !== false) {
				let replace = cosh(floatval(matches[11][key]));
			} elseif (strpos(found, "HSIN(") !== false) {
				let replace = sinh(floatval(matches[12][key]));
			} elseif (strpos(found, "HTAN(") !== false) {
				let replace = tanh(floatval(matches[13][key]));
			} elseif (strpos(found, "COS(") !== false) {
				let replace = cos(floatval(matches[5][key]));
			} elseif (strpos(found, "SIN(") !== false) {
				let replace = sin(floatval(matches[6][key]));
			} elseif (strpos(found, "TAN(") !== false) {
				let replace = tan(floatval(matches[7][key]));
			} elseif (strpos(found, "EXP(") !== false) {
				let replace = exp(floatval(matches[14][key]));
			} elseif (strpos(found, "SQR(") !== false) {
				let replace = sqrt(floatval(matches[15][key]));
			} elseif (strpos(found, "LOG(") !== false) {
				let splits = explode(",", matches[16][key]);
				if (count(splits) > 1) {
					let replace = log(floatval(splits[0]), floatval(splits[1]));
				} else {
					let replace = log(floatval(splits[0]));
				}
			} elseif (strpos(found, "LOG10(") !== false) {
				let replace = log10(matches[17][key]);
			} elseif (strpos(found, "HEX$(") !== false) {
				let replace = str_pad(dechex(intval(matches[18][key])), 8, "0", 0);
			} elseif (strpos(found, "BIN$(") !== false) {
				let replace = str_pad(decbin(intval(matches[19][key])), 32, "0", 0);
			}

			if (add_qoutes) {
				let replace = "\"" . replace . "\"";
			}

			let command = str_replace(found, replace, command);
		}

		return command;
	}

	public static function parse(
		string command,		
		event_manager = null,
		array globals = [],
		var config = null
	) {


		return null;
	}
}
