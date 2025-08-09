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
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("ABS", find);
		if (empty(cleaned)) {
			throw new Exception("Invalid ABS");
		}

		return str_replace(find, "abs(" . cleaned . ")", arg);
	}

	public function processAcos(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("ACOS", find);
		if (empty(cleaned)) {
			throw new Exception("Invalid ACOS");
		}

		return str_replace(find, "acos(floatval(" . cleaned . "))", arg);
	}

	public function processAsin(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("ASIN", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid ASIN");
		}

		return str_replace(find, "asin(floatval(" . cleaned . "))", arg);
	}

	public function processAtan(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("ATAN", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid ATAN");
		}

		return str_replace(find, "atan(floatval(" . cleaned . "))", arg);
	}

	public function processBin(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("BIN", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid BIN");
		}

		return str_replace(find, "str_pad(decbin(intval(" . cleaned . ")), 32, '0', 0)", arg);
	}

	public function processCos(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("COS", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid COS");
		}

		return str_replace(find, "cos(floatval(" . cleaned . "))", arg);
	}

	public function processExp(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("EXP", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid EXP");
		}

		return str_replace(find, "exp(floatval(" . cleaned . "))", arg);
	}

	public function processFrac(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("FRAC", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid FRAC");
		}

		return str_replace(find, "fmod(" . cleaned . ", 1)", arg);
	}

	public function processHCos(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("HCOS", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid HCOS");
		}

		return str_replace(find, "cosh(floatval(" . cleaned . "))", arg);
	}

	public function processHex(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("HEX", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid HEX");
		}

		return str_replace(find, "str_pad(dechex(intval(". cleaned . ")), 8, '0', 0)", arg);
	}

	public function processHSin(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("HSIN", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid HSIN");
		}

		return str_replace(find, "sinh(floatval(" . cleaned . "))", arg);
	}

	public function processHTan(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("HTAN", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid HTAN");
		}

		return str_replace(find, "tanh(floatval(" . cleaned . "))", arg);
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
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("LOG10", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid LOG10");
		}

		return str_replace(find, "log10(floatval(" . cleaned . "))", arg);
	}

	public function processRnd(arg)
	{
		var args, cleaned, find;

		if (arg == "RND") {
			return str_replace(arg, "rand(1, 10)", arg);
		}

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("RND", find);
		if (empty(cleaned)) {
			throw new Exception("Invalid RND");
		}

		let args = this->commaSplit(cleaned);
		if (count(args) != 2) {
			throw new Exception("Invalid RND");
		}

		return str_replace(find, "rand(intval(" . args[0] . "), intval(" . args[1] . "))", arg);
	}

	public function processSin(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("SIN", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid SIN");
		}

		return str_replace(find, "sin(floatval(" . cleaned . "))", arg);
	}

	public function processSgn(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("SGN", find);
		if (empty(cleaned) && cleaned != 0) {
			throw new Exception("Invalid SGN");
		}

		return str_replace(find, "((floatval(" . cleaned . ") > 0) ? 1 : ((floatval(" . cleaned . ") < 0) ? -1 : 0))", arg);
	}

	public function processSqr(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("SQR", find);
		if (empty(cleaned)) {
			throw new Exception("Invalid SQR");
		}

		return str_replace(find, "sqrt(floatval(" . cleaned . "))", arg);
	}

	public function processTan(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("TAN", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid TAN");
		}

		return str_replace(find, "tan(floatval(" . cleaned . "))", arg);
	}
}
