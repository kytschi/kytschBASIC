/**
 * Input Events parser
 *
 * @package     KytschBASIC\Parsers\Core\Input\InputEvents
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
namespace KytschBASIC\Parsers\Core\Input;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class InputEvents extends Command
{
	public keys = [
		"enter": 13,
		"!": 33,
		"\"": 34,
		"#": 35,
		"$": 36,
		"%": 37,
		"&": 38,
		"'": 39,
		"(": 40,
		")": 41,
		"*": 42,
		"+": 43,
		",": 44,
		"-": 45,
		".": 46,
		"/": 47,
		"0": 48,
		"1": 49,
		"2": 50,
		"3": 51,
		"4": 52,
		"5": 53,
		"6": 54,
		"7": 55,
		"8": 56,
		"9": 57,
		":": 58,
		";": 59,
		"<": 60,
		"=": 61,
		">": 62,
		"?": 63,
		"@": 64,
		"A": 65,
		"B": 66,
		"C": 67,
		"D": 68,
		"E": 69,
		"F": 70,
		"G": 71,
		"H": 72,
		"I": 73,
		"J": 74,
		"K": 75,
		"L": 76,
		"M": 77,
		"N": 78,
		"O": 79,
		"P": 80,
		"Q": 81,
		"R": 82,
		"S": 83,
		"T": 84,
		"U": 85,
		"V": 86,
		"W": 87,
		"X": 88,
		"Y": 89,
		"Z": 90,
		"[": 91,
		"\\": 92,
		"]": 93,
		"^": 94,
		"`": 96,
		"a": 97,
		"b": 98,
		"c": 99,
		"d": 100,
		"e": 101,
		"f": 102,
		"g": 103,
		"h": 104,
		"i": 105,
		"j": 106,
		"k": 107,
		"l": 108,
		"m": 109,
		"n": 110,
		"o": 111,
		"p": 112,
		"q": 113,
		"r": 114,
		"s": 115,
		"t": 116,
		"u": 117,
		"v": 118,
		"x": 119,
		"y": 120,
		"z": 121,
		"{": 123,
		"|": 124,
		"}": 125,
		"~": 126,
		"£": 163,
		"¬": 172
	];

	public function parse(string line, string command, array args, bool in_javascript = false)
	{
		switch(command) {
			case "KEYBOARDEVENT":
				return this->processKeyboardEvent(args);
			case "END KEYBOARDEVENT":
				return "}});});</script>";
			default:
				return null;
		}
	}

	private function processKeyboardEvent(array args)
	{
		var output = "<script type='text/javascript'>$(document).ready(function() {$('body').on('keypress', function(event) {";
		
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let args[0] = trim(args[0], "\"");
			if (!isset(this->keys[args[0]])) {
				throw new Exception("Invalid KEYBOARDEVENT, key not supported.");
			}

			let output .= "if (event.which == " . this->keys[args[0]] . ") {";
		} else {
			throw new Exception("Invalid KEYBOARDEVENT.");
		}

		return output;
	}
}
