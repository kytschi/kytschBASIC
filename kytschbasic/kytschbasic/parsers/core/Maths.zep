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

use KytschBASIC\Exceptions\Exception;
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
        var args, find;

        let find = arg;
        let args = this->equalsSplit(arg);
        if (count(args) > 1) {
            let find = args[1];
        }
		if (substr(find, 0, 5) == "LOG10") {
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
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("ABS", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid ABS");
			}
			return str_replace(args[1], "abs(" . cleaned . ")", arg);
		}

		let cleaned = this->cleanArg("ABS", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid ABS");
		}

		return str_replace(arg, "\"\" . abs(" . cleaned . ") . \"\"", arg);
	}

	public function processAcos(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("ACOS", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid ACOS");
			}
			return str_replace(args[1], "acos(floatval(" . cleaned . "))", arg);
		}

		let cleaned = this->cleanArg("ACOS", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid ACOS");
		}

		return str_replace(arg, "\"\" . acos(floatval(" . cleaned . ")) . \"\"", arg);
	}

	public function processAsin(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("ASIN", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid ASIN");
			}
			return str_replace(args[1], "asin(floatval(" . cleaned . "))", arg);
		}

		let cleaned = this->cleanArg("ASIN", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid ASIN");
		}

		return str_replace(arg, "\"\" . asin(floatval(" . cleaned . ")) . \"\"", arg);
	}

	public function processAtan(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("ATAN", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid ATAN");
			}
			return str_replace(args[1], "atan(floatval(" . cleaned . "))", arg);
		}

		let cleaned = this->cleanArg("ATAN", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid ATAN");
		}

		return str_replace(arg, "\"\" . atan(floatval(" . cleaned . ")) . \"\"", arg);
	}

	public function processBin(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("BIN", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid BIN");
			}
			return str_replace(args[1], "str_pad(decbin(intval(" . cleaned . ")), 32, '0', 0)", arg);
		}

		let cleaned = this->cleanArg("BIN", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid BIN");
		}

		return str_replace(arg, "\"\" . str_pad(decbin(intval(" . cleaned . ")), 32, '0', 0) . \"\"", arg);
	}

	public function processCos(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("COS", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid COS");
			}
			return str_replace(args[1], "cos(floatval(" . cleaned . "))", arg);
		}

		let cleaned = this->cleanArg("COS", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid COS");
		}

		return str_replace(arg, "\"\" . cos(floatval(" . cleaned . ")) . \"\"", arg);
	}

	public function processExp(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("EXP", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid EXP");
			}
			return str_replace(args[1], "exp(floatval(" . cleaned . "))", arg);
		}

		let cleaned = this->cleanArg("EXP", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid EXP");
		}

		return str_replace(arg, "\"\" . exp(floatval(" . cleaned . ")) . \"\"", arg);
	}

	public function processFrac(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("FRAC", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid FRAC");
			}
			return str_replace(args[1], "fmod(" . cleaned . ", 1)", arg);
		}

		let cleaned = this->cleanArg("FRAC", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid FRAC");
		}

		return str_replace(arg, "\"\" . fmod(" . cleaned . ", 1) . \"\"", arg);
	}

	public function processHCos(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("HCOS", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid HCOS");
			}
			return str_replace(args[1], "cosh(floatval(" . cleaned . "))", arg);
		}

		let cleaned = this->cleanArg("HCOS", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid HCOS");
		}

		return str_replace(arg, "\"\" . cosh(floatval(" . cleaned . ")) . \"\"", arg);
	}

	public function processHex(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("HEX", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid HEX");
			}
			return str_replace(args[1], "str_pad(dechex(intval(". cleaned . ")), 8, '0', 0)", arg);
		}

		let cleaned = this->cleanArg("HEX", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid HEX");
		}

		return str_replace(arg, "\"\" . str_pad(dechex(intval(". cleaned . ")), 8, '0', 0) . \"\"", arg);
	}

	public function processHSin(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("HSIN", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid HSIN");
			}
			return str_replace(args[1], "sinh(floatval(" . cleaned . "))", arg);
		}

		let cleaned = this->cleanArg("HSIN", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid HSIN");
		}

		return str_replace(arg, "\"\" . sinh(floatval(" . cleaned . ")) . \"\"", arg);
	}

	public function processHTan(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("HTAN", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid HTAN");
			}
			return str_replace(args[1], "tanh(floatval(" . cleaned . "))", arg);
		}

		let cleaned = this->cleanArg("HTAN", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid HTAN");
		}

		return str_replace(arg, "\"\" . tanh(floatval(" . cleaned . ")) . \"\"", arg);
	}

	public function processLog(arg)
	{
		var args, cleaned, find;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
            let find = args[1];
			let cleaned = this->cleanArg("LOG", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid LOG");
			}

			let args = this->commaSplit(cleaned);
			if (count(args) > 1) {
				return str_replace(find, "log(floatval(" . args[0]. "), floatval(" . args[1] . "))", arg);
			}
			return str_replace(find, "log(floatval(" . cleaned. "))", arg);
		}

		let cleaned = this->cleanArg("LOG", arg);

		let args = this->commaSplit(cleaned);
		if (count(args) > 1) {
			return str_replace(arg, "\"\" . log(floatval(" . args[0]. "), floatval(" . args[1] . ")) . \"\"", arg);
		}

		return str_replace(arg, "\"\" . log(floatval(" . cleaned . ")) . \"\"", arg);
	}

	public function processLog10(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("LOG10", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid LOG10");
			}
			return str_replace(args[1], "log10(floatval(" . cleaned . "))", arg);
		}

		let cleaned = this->cleanArg("LOG10", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid LOG10");
		}

		return str_replace(arg, "\"\" . log10(floatval(" . cleaned . ")) . \"\"", arg);
	}

	public function processRnd(arg)
	{
		var args, cleaned, find;

		if (arg == "RND") {
			return str_replace(arg, "\"\" . rand(1, 10) . \"\"", arg);
		}

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
            let find = args[1];
			let cleaned = this->cleanArg("RND", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid RND");
			}

			let args = this->commaSplit(cleaned);
			if (count(args) != 2) {
				throw new Exception("Invalid RND");
			}
			return str_replace(find, "rand(floatval(" . args[0]. "), floatval(" . args[1] . "))", arg);
		}

		let cleaned = this->cleanArg("RND", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid RND");
		}

		let args = this->commaSplit(cleaned);
		if (count(args) != 2) {
			throw new Exception("Invalid RND");
		}

		return str_replace(arg, "\"\" . rand(intval(" . args[0] . "), intval(" . args[1] . ")) . \"\"", arg);
	}

    public function processSgn(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("SGN", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid SIN");
			}
			return str_replace(args[1], "((floatval(" . cleaned . ") > 0) ? 1 : ((floatval(" . cleaned . ") < 0) ? -1 : 0))", arg);
		}

		let cleaned = this->cleanArg("SGN", arg);
		if (empty(cleaned) && cleaned != 0) {
			throw new Exception("Invalid SGN");
		}

		return str_replace(arg, "\"\" . ((floatval(" . cleaned . ") > 0) ? 1 : ((floatval(" . cleaned . ") < 0) ? -1 : 0)) . \"\"", arg);
	}

	public function processSin(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("SIN", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid SIN");
			}
			return str_replace(args[1], "sin(floatval(" . cleaned . "))", arg);
		}

		let cleaned = this->cleanArg("SIN", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid SIN");
		}

		return str_replace(arg, "\"\" . sin(floatval(" . cleaned . ")) . \"\"", arg);
	}

	public function processSqr(arg)
	{
		var args, cleaned;

		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("SQR", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid SQR");
			}
			return str_replace(args[1], "sqrt(floatval(" . cleaned . "))", arg);
		}

		let cleaned = this->cleanArg("SQR", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid SQR");
		}

		return str_replace(arg, "\"\" . sqrt(floatval(" . cleaned . ")) . \"\"", arg);
	}

	public function processTan(arg)
	{
		var args, cleaned;

        let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let cleaned = this->cleanArg("TAN", args[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid TAN");
			}
			return str_replace(args[1], "tan(floatval(" . cleaned . "))", arg);
		}

		let cleaned = this->cleanArg("TAN", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid TAN");
		}

		return str_replace(arg, "\"\" . tan(floatval(" . cleaned . ")) . \"\"", arg);
	}
}
