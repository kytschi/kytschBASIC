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

	public function isEquation(line)
	{
		return preg_split("/([+\-\/\*])(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", line, 0, 2);
	}

	public function processValue(arg)
	{

		if (substr(arg, 0, 5) == "LOG10") {
			return this->processLog10(arg);
		}

		switch (this->getCommand(arg)) {
			case "ABS":
				return this->processAbs(arg);
			case "ACOS":
				return this->processAcos(arg);
			case "ASIN":
				return this->processAsin(arg);
			case "ATAN":
				return this->processAtan(arg);
			case "BIN":
				return this->processBin(arg);
			case "COS":
				return this->processCos(arg);
			case "EXP":
				return this->processExp(arg);
			case "FRAC":
				return this->processFrac(arg);
			case "HCOS":
				return this->processHCos(arg);
			case "HEX":
				return this->processHex(arg);
			case "HSIN":
				return this->processHSin(arg);
			case "HTAN":
				return this->processHTan(arg);
			case "LOG":
				return this->processLog(arg);
			case "RND":
				return this->processRnd(arg);
			case "SIN":
				return this->processSin(arg);
			case "SGN":
				return this->processSgn(arg);
			case "SQR":
				return this->processSqr(arg);
			case "TAN":
				return this->processTan(arg);
			default:
				return null;
		}
	}

	public function processAbs(arg)
	{
		let arg = this->cleanArg("ABS", arg);
		return "abs(" . arg . ")";
	}

	public function processAcos(arg)
	{
		let arg = this->cleanArg("ACOS", arg);
		return "acos(floatval(" . arg . "))";
	}

	public function processAsin(arg)
	{
		let arg = this->cleanArg("ASIN", arg);
		return "asin(floatval(" . arg . "))";
	}

	public function processAtan(arg)
	{
		let arg = this->cleanArg("ATAN", arg);
		return "atan(floatval(" . arg . "))";
	}

	public function processBin(arg)
	{
		let arg = this->cleanArg("BIN", arg);
		return "str_pad(decbin(intval(" . arg . ")), 32, '0', 0)";
	}

	public function processCos(arg)
	{
		let arg = this->cleanArg("COS", arg);
		return "cos(floatval(" . arg . "))";
	}

	public function processExp(arg)
	{
		let arg = this->cleanArg("EXP", arg);
		return "exp(floatval(" . arg . "))";
	}

	public function processFrac(arg)
	{
		let arg = this->cleanArg("FRAC", arg);
		return "fmod(" . arg . ", 1)";
	}

	public function processHCos(arg)
	{
		let arg = this->cleanArg("HCOS", arg);
		return "cosh(floatval(" . arg . "))";
	}

	public function processHex(arg)
	{
		let arg = this->cleanArg("HEX", arg);
		return "str_pad(dechex(intval(". arg . ")), 8, '0', 0)";
	}

	public function processHSin(arg)
	{
		let arg = this->cleanArg("HSIN", arg);
		return "sinh(floatval(" . arg . "))";
	}

	public function processHTan(arg)
	{
		let arg = this->cleanArg("HTAN", arg);
		return "tanh(floatval(" . arg . "))";
	}

	public function processLog(arg)
	{
		var args;

		let arg = this->cleanArg("LOG", arg);

		let args = this->commaSplit(arg);
		
		if (count(args) > 1) {
			return "log(floatval(" . args[0]. "), floatval(" . args[1] . "))";
		}

		return "log(floatval(" . arg . "))";		
	}

	public function processLog10(arg)
	{
		let arg = this->cleanArg("LOG10", arg);
		return "log10(floatval(" . arg . "))";
	}

	public function processRnd(arg)
	{
		let arg = ltrim(rtrim(trim(str_replace("RND", "", arg)), ")"), "(");

		if (empty(arg)) {
			return rand(1, 10);
		}
		
		if (count(arg) == 1) {
			return "rand(1, intval(" . arg. "))";
		}

		return "rand(intval(" . arg . "), intval(" . this->outputArg(arg[1], false). "))";
	}

	public function processSin(arg)
	{
		let arg = this->cleanArg("SIN", arg);
		return "sin(floatval(" . arg . "))";
	}

	public function processSgn(arg)
	{
		let arg = this->cleanArg("SGN", arg);

		if (empty(arg)) {
			let arg = 0;
		}

		let arg = arg;

		return "((floatval(" . arg . ") > 0) ? 1 : ((floatval(" . arg . ") < 0) ? -1 : 0))";
	}

	public function processSqr(arg)
	{
		let arg = this->cleanArg("SQR", arg);
		return "sqrt(floatval(" . arg . "))";
	}

	public function processTan(arg)
	{
		let arg = this->cleanArg("TAN", arg);
		return "tan(floatval(" . arg . "))";
	}
}
