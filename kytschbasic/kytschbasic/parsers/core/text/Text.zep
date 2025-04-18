/**
 * Text parser
 *
 * @package     KytschBASIC\Parsers\Core\Text\Text
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
namespace KytschBASIC\Parsers\Core\Text;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Text extends Command
{
	public function parse(string line, string command, array args)
	{
		switch(command) {
			case "END SWRITE":
				return "</p>";
			case "PRINT":
				return this->processPrint(args);
			case "SWRITE":
				return this->processSWrite(args);
			case "LINE BREAK":
				return "<br/>";
			default:
				return null;
		}
	}

	private function processPrint(array args)
	{
		var value="", output = "<?= \"<span";
				
		let value = args[0];
						
		if (isset(args[1]) && !empty(args[1])) {
			let output .= " class=" . this->outputArg(args[1]);
		}

		if (isset(args[2]) && !empty(args[2])) {
			let output .= " id=" . this->outputArg(args[2]);
		} else {
			let output .= " id=" . this->outputArg(this->genID("kb-span"), true);
		}

		if (isset(args[3]) && !empty(args[3])) {
			let output .= " title=" . this->outputArg(args[3]);
		}
		
		return output . ">\" . " . args[0] . " . \"</span>\";?>";
	}

	public function processPadding(string text, int length, string dir = "right")
	{
		var spaces="", end;

		if (length > strlen(text)) {
			let end = length - strlen(text);
			
			while end {
				let spaces .= "&nbsp;";
				let end -= 1;
			}
		}

		return (dir == "left" ? spaces : "") . substr(text, 0, length) . (dir == "right" ? spaces : "");
	}

	private function processSWrite(array args)
	{
		var output = "<?= \"<p";
		
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= " class=" . this->outputArg(args[0]);
		}

		if (isset(args[1]) && !empty(args[1])) {
			let output .= " id=" . this->outputArg(args[1]);
		} else {
			let output .= " id=" . this->outputArg(this->genID("kb-span"), true);
		}
		
		return output. ">\"; ?>";
	}

	public function processValue(arg)
	{
		switch (this->getCommand(arg)) {
			case "ASC":
				return this->processAsc(arg);
			case "CENTRE":
				return this->processCentre(arg);
			case "CHR":
				return this->processChr(arg);
			case "INSTR":
				return this->processInstr(arg);
			case "INT":
				return this->processInt(arg);
			case "LCASE":
				return this->processLCase(arg);
			case "LEFT":
				return this->processLeft(arg);
			case "LEN":
				return this->processLen(arg);
			case "LSET":
				return this->processLSet(arg);
			case "MID":
				return this->processMid(arg);
			case "REPLACE":
				return this->processReplace(arg);
			case "RIGHT":
				return this->processRight(arg);
			case "RSET":
				return this->processRSet(arg);
			case "STR":
				return this->processToString(arg);
			case "STRING":
				return this->processStringSetup(arg);
			case "STRIPLEAD":
				return this->processStripLead(arg);
			case "STRIPTRAIL":
				return this->processStripTrail(arg);
			case "UCASE":
				return this->processUCase(arg);
			case "UNLEFT":
				return this->processUnLeft(arg);
			case "UNRIGHT":
				return this->processUnRight(arg);
			case "VAL":
				return this->processVal(arg);
			default:
				return null;
		}
	}

	public function processAsc(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("ASC", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid ASC");
		}

		return str_replace(find, "ord(" . cleaned . ")", arg);
	}

	public function processCentre(arg)
	{
		var args, cleaned, find, length = 1;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("CENTRE", find);
		if (empty(cleaned)) {
			throw new Exception("Invalid CENTRE");
		}

		let args = this->commaSplit(cleaned);
		if (!count(args)) {
			throw new Exception("Invalid CENTRE");
		}

		if (isset(args[1]) && !empty(args[1])) {
			let length = args[1];
		}

		return str_replace(find, "substr(" . args[0] . ", intval(strlen(" . args[0] . ") / 2) - 1, intval(" . length . "))", arg);
	}

	public function processChr(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("CHR", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid CHR");
		}

		return str_replace(find, "chr(intval(" . cleaned . "))", arg);
	}

	public function processInstr(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("INSTR", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid INSTR");
		}

		let args = this->commaSplit(cleaned);
		if (!count(args)) {
			throw new Exception("Invalid INSTR");
		}

		return str_replace(find, "strpos(" . args[0] . ", " . args[1] . ")", arg);
	}

	public function processInt(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("INT", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid INT");
		}

		return str_replace(find, "intval(" . cleaned . ")", arg);
	}

	public function processLCase(arg)
	{	
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("LCASE", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid LCASE");
		}

		return str_replace(find, "strtolower(" . cleaned . ")", arg);
	}

	public function processLeft(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("LEFT", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid LEFT");
		}

		let args = this->commaSplit(cleaned);
		if (!count(args)) {
			throw new Exception("Invalid LEFT");
		}

		return str_replace(find, "substr(" . args[0] . ", 0,  intval(" . args[1] . "))", arg);
	}

	public function processLen(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("LEN", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid LEN");
		}

		return str_replace(find, "strlen(" . cleaned . ")", arg);
	}

	public function processLSet(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("LSET", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid LSET");
		}

		let args = this->commaSplit(cleaned);
		if (count(args) < 1) {
			throw new Exception("Invalid LSET");
		}

		return str_replace(find, "(new KytschBASIC\\Parsers\\Core\Text\\Text())->processPadding(" . args[0] . ", intval(" . args[1] . "), 'left')", arg);
	}

	public function processMid(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("MID", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid MID");
		}

		let args = this->commaSplit(cleaned);
		if (count(args) < 2) {
			throw new Exception("Invalid MID");
		}

		return str_replace(find, "substr(" . args[0] . ", (" . args[1] . " - 1), " . args[2] . ")", arg);
	}

	public function processReplace(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("REPLACE", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid REPLACE");
		}

		let args = this->commaSplit(cleaned);
		if (count(args) < 2) {
			throw new Exception("Invalid REPLACE");
		}
		
		return str_replace(find, "str_replace(" . args[1] . ", " . args[2] . ", " . args[0] . ")", arg);
	}

	public function processRight(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("RIGHT", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid RIGHT");
		}

		let args = this->commaSplit(cleaned);
		if (!count(args)) {
			throw new Exception("Invalid RIGHT");
		}

		return str_replace(find, "substr(" . args[0] . ", intval(strlen(" . args[0] . ")) - intval(" . args[1] . "),  intval(" . args[1] . "))", arg);
	}

	public function processRSet(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("RSET", find);

		if (empty(cleaned)) {
			throw new Exception("Invalid RSET");
		}

		let args = this->commaSplit(cleaned);
		if (count(args) < 1) {
			throw new Exception("Invalid RSET");
		}

		return str_replace(find, "(new KytschBASIC\\Parsers\\Core\Text\\Text())->processPadding(" . args[0] . ", intval(" . args[1] . "))", arg);
	}

	public function processStringSetup(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("STRING", find);
		if (empty(cleaned)) {
			throw new Exception("Invalid STRING");
		}

		let args = this->commaSplit(cleaned);
		if (count(args) < 1) {
			throw new Exception("Invalid STRING");
		}

		return str_replace(find, "(new KytschBASIC\\Parsers\\Core\Text\\Text())->processString(" . args[0] . ", intval(" . args[1] . "))", arg);
	}

	public function processString(converted, length)
	{
		var value = "";

		while length {
			let value .= converted;
			let length -= 1;
		}

		return value;
	}

	public function processStripLead(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("STRIPLEAD", find);
		if (empty(cleaned)) {
			throw new Exception("Invalid STRIPLEAD");
		}

		let args = this->commaSplit(cleaned);
		if (count(args) < 1) {
			throw new Exception("Invalid STRIPLEAD");
		}

		return str_replace(find, "ltrim(" . args[0] . ", (is_numeric(" . args[1] . ") ? chr(intval(" . args[1] . ")) : " . args[1] . "))", arg);
	}

	public function processStripTrail(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("STRIPLEAD", find);
		if (empty(cleaned)) {
			throw new Exception("Invalid STRIPLEAD");
		}

		let args = this->commaSplit(cleaned);
		if (count(args) < 1) {
			throw new Exception("Invalid STRIPLEAD");
		}

		return str_replace(find, "rtrim(" . args[0] . ", (is_numeric(" . args[1] . ") ? chr(intval(" . args[1] . ")) : " . args[1] . "))", arg);
	}

	public function processToString(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("STR", find);
		if (empty(cleaned)) {
			throw new Exception("Invalid STR");
		}

		return str_replace(find, "(string)" . cleaned, arg);
	}

	public function processUCase(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("UCASE", find);
		if (empty(cleaned)) {
			throw new Exception("Invalid UCASE");
		}

		return str_replace(find, "strtoupper(" . cleaned . ")", arg);
	}

	public function processUnLeft(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("UNLEFT", find);
		if (empty(cleaned)) {
			throw new Exception("Invalid UNLEFT");
		}

		let args = this->commaSplit(cleaned);
		if (count(args) < 1) {
			throw new Exception("Invalid UNLEFT");
		}

		return str_replace(find, "substr(" . args[0] . ", intval(" . args[1] . ") - 1,  intval(strlen(" . args[0] . ")))", arg);
	}

	public function processUnRight(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("UNRIGHT", find);
		if (empty(cleaned)) {
			throw new Exception("Invalid UNRIGHT");
		}

		let args = this->commaSplit(cleaned);
		if (count(args) < 1) {
			throw new Exception("Invalid UNRIGHT");
		}

		return str_replace(find, "substr(" . args[0] . ", 0,  intval(strlen(" . args[0] . ")) - intval(" . args[1] . "))", arg);
	}

	public function processVal(arg)
	{
		var args, cleaned, find;

		let find = arg;
		let args = this->equalsSplit(arg);
		if (count(args) > 1) {
			let find = args[1];
		}

		let cleaned = this->cleanArg("VAL", find);
		if (empty(cleaned)) {
			throw new Exception("Invalid VAL");
		}

		return str_replace(find, "floatval(" . cleaned . ")", arg);
	}
}
