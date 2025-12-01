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
	public function parse(string line, string command, array args, bool in_javascript = false, bool in_event = false)
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
			case "WHILE":
				return this->processWhile(args);
			default:
				return null;
		}
	}

	private function processFor(string line, array args)
	{
		var splits;

		if (empty(args[0])) {
			throw new Exception("Invalid FOR");
		}

		let splits = preg_split("/\\bIN\\b(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", args[0]);
		if (count(splits) > 1) {
			return this->processForIn(splits);
		}

		let splits = preg_split("/\\bTO\\b(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", args[0]);
		if (count(splits) <= 1) {
			throw new Exception("Invalid FOR TO");
		}

		return this->processForTo(splits, args);
	}

	private function processForIn(args)
	{
		var arg;

		if (!count(args)) {
			throw new Exception("Invalid FOR IN");
		}

		for arg in this->types {
			if (strpos(args[1], arg) !== false) {
				let args[1] = "$" . str_replace(this->types, "", trim(args[1]));
				break;
			}
		}

		return "<?php foreach (" .
			trim(args[1]) .
			" as " .
			trim(args[0]) . ") { ?>";
	}

	private function processForTo(splits, args)
	{
		var output = "<?php for (", variable, step, dir = " <= ", subvars;

		if (!count(args)) {
			throw new Exception("Invalid FOR TO");
		}

		let splits[0] = str_replace("FOR ", "", trim(splits[0]));
		let subvars = this->equalsSplit(splits[0]);
		if (count(subvars) <= 1) {
			throw new Exception("Invalid FOR TO");
		}
		let variable = subvars[0];
		
		let args = explode(" STEP ", trim(splits[1]), 2);
						
		let output .= variable . " = intval(" . subvars[1] . "); " . variable;

		if (isset(args[1])) {
			let args[1] = intval(args[1]);
			if (args[1] < 0) {
				let dir = " >= ";
				let step = " -= " . trim(args[1], "-");
			} else {
				let step = " += " . args[1];
			}
		} else {
			let step = " += 1";
		}	

		let output .= dir . "intval(" . args[0] . "); " . variable . step;

		return output . ") { ?>";
	}
	
	private function processWhile(args)
	{
		var output = "<?php while (";

		if (!count(args)) {
			throw new Exception("Invalid WHILE");
		}

		let output .= this->setDoubleEquals(rtrim(ltrim(args[0], "["), "]"));

		return output . ") { ?>";
	}
}