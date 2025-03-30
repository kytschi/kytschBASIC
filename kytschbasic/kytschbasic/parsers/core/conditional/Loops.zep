/**
 * Loops parser
 *
 * @package     KytschBASIC\Parsers\Core\Conditional\Loops
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
namespace KytschBASIC\Parsers\Core\Conditional;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Maths;

class Loops extends Command
{
	public function parse(string command, args)
	{
		if (command == "WHILE") {
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

		return null;
	}

	private function processForIn(args)
	{
		let args = explode(" IN ", args);
		if (count(args) < 1) {
			throw new Exception("Invalid for loop");
		}

		return "<?php foreach (" .
			this->cleanVarOnly(args[1]) .
			" as " .
			this->cleanVarOnly(args[0]) . ") { ?>";
	}

	private function processForTo(args)
	{
		let args = explode(" TO ", args);
		if (count(args) < 1) {
			throw new Exception("Invalid for loop");
		}

		var variable, step, dir = " <= ", start = 0, end = 1;
		let variable = explode("=", args[0]);

		let start = this->clean(variable[1], false);
		let end = this->clean(args[1], this->isVariable(args[1])) ;

		let variable = "$" . str_replace(")", "]", str_replace("(", "[", str_replace(this->types, "", variable[0])));

		let step = explode(" STEP ", args[1]);
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

		return "<?php for (" .
			variable . " = intval(" . start . "); " .
			this->clean(variable, false) .
			dir .
			"intval(" . end . "); " .
			this->clean(variable, false) . step . ") { ?>";
	}
	
	private function processWhile(args)
	{
		var output = "<?php while (";

		let output .= (new Maths())->equation(args);

		return output . ") { ?>";
	}
}