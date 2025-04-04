/**
 * Loops parser
 *
 * @package     KytschBASIC\Parsers\Core\Conditional\Loops
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
namespace KytschBASIC\Parsers\Core\Conditional;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Maths;

class Loops extends Command
{
	public function parse(string line, string command, array args)
	{
		switch (command) {
			case "FOR":
				return this->processFor(line, args);
			case "WEND":
				return "<?php } ?>";
			case "NEXT":
				return "<?php } ?>";
			case "END WHILE":
				return "<?php } ?>";
			default:
				return null;
		}
		/*if (command == "WHILE") {
			return this->processWhile(args);
		} elseif (command == "WEND" || command == "NEXT" || command == "END WHILE") {
			return "<?php } ?>";
		} elseif (command == "FOR") {
			if (strpos(args, " IN ") !== false) {
				return this->processForIn(args);
			} else {
				return this->processForTo(args);
			}
		}

		return null;*/
	}

	private function processFor(string line, array args)
	{
		var splits;

		if (empty(args[0])) {
			throw new Exception("Invalid FOR statement");
		}

		let splits = preg_split("/\\bIN\\b(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", args[0]);
		if (count(splits) > 1) {
			return this->processForIn(splits);
		}

		let splits = preg_split("/\\bTO\\b(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", line);
		if (count(splits) <= 1 || count(args) <= 1) {
			throw new Exception("Invalid FOR statement");
		}

		return this->processForTo(args);
	}

	private function processForIn(args)
	{
		return "<?php foreach (" .
			trim(args[1]) .
			" as " .
			trim(args[0]) . ") { ?>";
	}

	private function processForTo(args)
	{
		var output = "<?php for (", variable, step, dir = " <= ";

		let variable = args[0];

		let args = explode(" TO ", args[1], 2);
				
		let output .= variable . " = intval(" . args[0] . "); " . variable;

		let step = explode(" STEP ", args[1], 2);
		if (count(step) > 1) {
			let args[1] = step[0];
			let step[1] = intval(step[1]);
			if (step[1] < 0) {
				let dir = " >= ";
				let step = " -= " . trim(step[1], "-");
			} else {
				let step = " += " . step[1];
			}
		} else {
			let step = " += 1";
		}	

		let output .= dir . "intval(" . args[1] . "); " . variable . step;

		return output . ") { ?>";
	}
	
	private function processWhile(args)
	{
		var output = "<?php while (";

		return output . ") { ?>";
	}
}