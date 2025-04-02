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

	/*public function equation(command)
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

	public function parse(string line, string command, array args)
	{
		if (substr(command, 0, 1) == "\"") {
			return null;
		}

		return this->processValue(this->args(args));
	}

	public function processValue(args)
	{
		if (is_string(args)) {
			let args = [args];
		}

		if (substr(args[0], 0, 5) == "LOG10") {
			return this->processLog10(args);
		}

		switch (this->getCommand(args[0])) {
			case "ABS":
				return this->processAbs(args);
			case "ACOS":
				return this->processAcos(args);
			case "ASIN":
				return this->processAsin(args);
			case "ATAN":
				return this->processAtan(args);
			case "BIN":
				return this->processBin(args);
			case "COS":
				return this->processCos(args);
			case "EXP":
				return this->processExp(args);
			case "FRAC":
				return this->processFrac(args);
			case "HCOS":
				return this->processHCos(args);
			case "HEX":
				return this->processHex(args);
			case "HSIN":
				return this->processHSin(args);
			case "HTAN":
				return this->processHTan(args);
			case "LOG":
				return this->processLog(args);
			case "RND":
				return this->processRnd(args);
			case "SIN":
				return this->processSin(args);
			case "SGN":
				return this->processSgn(args);
			case "SQR":
				return this->processSqr(args);
			case "TAN":
				return this->processTan(args);
			default:
				return null;
		}
	}

	public function processAbs(args)
	{
		let args[0] = this->cleanArg("ABS", args[0]);
		let args = this->args(args[0]);
		return "abs(" . this->outputArg(args[0], false) . ")";
	}

	public function processAcos(args)
	{
		let args[0] = this->cleanArg("ACOS", args[0]);
		let args = this->args(args[0]);
		return "acos(floatval(" . this->outputArg(args[0], false) . "))";
	}

	public function processAsin(args)
	{
		let args[0] = this->cleanArg("ASIN", args[0]);
		let args = this->args(args[0]);
		return "asin(floatval(" . this->outputArg(args[0], false) . "))";
	}

	public function processAtan(args)
	{
		let args[0] = this->cleanArg("ATAN", args[0]);
		let args = this->args(args[0]);
		return "atan(floatval(" . this->outputArg(args[0], false) . "))";
	}

	public function processBin(args)
	{
		let args[0] = this->cleanArg("BIN", args[0]);
		let args = this->args(args[0]);
		return "str_pad(decbin(intval(" . this->outputArg(args[0], false) . ")), 32, '0', 0)";
	}

	public function processCos(args)
	{
		let args[0] = this->cleanArg("COS", args[0]);
		let args = this->args(args[0]);
		return "cos(floatval(" . this->outputArg(args[0], false) . "))";
	}

	public function processExp(args)
	{
		let args[0] = this->cleanArg("EXP", args[0]);
		let args = this->args(args[0]);
		return "exp(floatval(" . this->outputArg(args[0], false) . "))";
	}

	public function processFrac(args)
	{
		let args[0] = this->cleanArg("FRAC", args[0]);
		let args = this->args(args[0]);
		return "fmod(" . this->outputArg(args[0], false) . ", 1)";
	}

	public function processHCos(args)
	{
		let args[0] = this->cleanArg("HCOS", args[0]);
		let args = this->args(args[0]);
		return "cosh(floatval(" . this->outputArg(args[0], false) . "))";
	}

	public function processHex(args)
	{
		let args[0] = this->cleanArg("HEX", args[0]);
		let args = this->args(args[0]);
		return "str_pad(dechex(intval(". this->outputArg(args[0], false) . ")), 8, '0', 0)";
	}

	public function processHSin(args)
	{
		let args[0] = this->cleanArg("HSIN", args[0]);
		let args = this->args(args[0]);
		return "sinh(floatval(" . this->outputArg(args[0], false) . "))";
	}

	public function processHTan(args)
	{
		let args[0] = this->cleanArg("HTAN", args[0]);
		let args = this->args(args[0]);
		return "tanh(floatval(" . this->outputArg(args[0], false) . "))";
	}

	public function processLog(args)
	{
		let args[0] = this->cleanArg("LOG", args[0]);
		let args = this->args(args[0]);

		if (count(args) > 1) {
			return "log(floatval(" . this->outputArg(args[0], false) . "), floatval(" . this->outputArg(args[1], false) . "))";
		}

		return "log(floatval(" . this->outputArg(args[0], false) . "))";		
	}

	public function processLog10(args)
	{
		let args[0] = this->cleanArg("LOG10", args[0]);
		let args = this->args(args[0]);

		return "log10(floatval(" . this->outputArg(args[0], false) . "))";
	}

	public function processRnd(args)
	{
		let args[0] = ltrim(rtrim(trim(str_replace("RND", "", args[0])), ")"), "(");

		if (empty(args[0])) {
			return rand(1, 10);
		}

		let args = this->args(args[0]);
		
		if (count(args) == 1) {
			return "rand(1, intval(" . this->outputArg(args[0], false). "))";
		}

		return "rand(intval(" . this->outputArg(args[0], false) . "), intval(" . this->outputArg(args[1], false). "))";
	}

	public function processSin(args)
	{
		let args[0] = this->cleanArg("SIN", args[0]);
		let args = this->args(args[0]);		
		return "sin(floatval(" . this->outputArg(args[0], false) . "))";
	}

	public function processSgn(args)
	{
		let args[0] = this->cleanArg("SGN", args[0]);
		let args = this->args(args[0]);

		if (empty(args[0])) {
			let args[0] = 0;
		}

		let args[0] = this->outputArg(args[0], false);

		return "((floatval(" . args[0] . ") > 0) ? 1 : ((floatval(" . args[0] . ") < 0) ? -1 : 0))";
	}

	public function processSqr(args)
	{
		let args[0] = this->cleanArg("SQR", args[0]);
		let args = this->args(args[0]);
		return "sqrt(floatval(" . this->outputArg(args[0], false) . "))";
	}

	public function processTan(args)
	{
		let args[0] = this->cleanArg("TAN", args[0]);
		let args = this->args(args[0]);
		return "tan(floatval(" . this->outputArg(args[0], false) . "))";
	}*/
}
