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
		
		if (isset(args[0]) && !empty(args[0])) {
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
		return "ord(" . this->cleanArg("ASC", arg) . ")";
	}

	public function processCentre(arg)
	{
		var args, length = 1;

		let arg = this->cleanArg("CENTRE", arg);

		if (empty(arg)) {
			throw new Exception("Invalid CENTRE");
		}

		let args = preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", arg);
		if (!count(args)) {
			throw new Exception("Invalid CENTRE");
		}
						
		if (isset(args[1]) && !empty(args[1])) {
			let length = args[1];
		}

		return "substr(" . args[0] . ", intval(strlen(" . args[0] . ") / 2) - 1, intval(" . length . "))";
	}

	public function processChr(arg)
	{
		return "chr(intval(" . this->cleanArg("CHR", arg) . "))";
	}

	public function processInstr(arg)
	{
		var args;

		let arg = this->cleanArg("INSTR", arg);

		if (empty(arg)) {
			throw new Exception("Invalid INSTR");
		}

		let args = preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", arg);
		if (!count(args)) {
			throw new Exception("Invalid INSTR");
		}

		return "strpos(" . args[0] . ", " . args[1] . ")";
	}

	public function processInt(arg)
	{
		return "intval(" . this->cleanArg("INT", arg) . ")";
	}

	public function processLCase(arg)
	{	
		return "strtolower(" . this->cleanArg("LCASE", arg) . ")";
	}

	public function processLeft(arg)
	{
		var args;

		let arg = this->cleanArg("LEFT", arg);

		if (empty(arg)) {
			throw new Exception("Invalid LEFT");
		}

		let args = preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", arg);
		if (count(args) < 1) {
			throw new Exception("Invalid LEFT");
		}

		return "substr(" . args[0] . ", 0,  intval(" . args[1] . "))";
	}

	public function processLen(arg)
	{
		return "strlen(" . this->cleanArg("LEN", arg) . ")";
	}

	public function processLSet(arg)
	{
		var args;

		let arg = this->cleanArg("LSET", arg);

		if (empty(arg)) {
			throw new Exception("Invalid LSET");
		}

		let args = preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", arg);
		if (count(args) < 1) {
			throw new Exception("Invalid LSET");
		}
					
		return "(new KytschBASIC\\Parsers\\Core\Text\\Text())->processPadding(" . args[0] . ", intval(" . args[1] . "), 'left')";
	}

	public function processMid(arg)
	{
		var args;

		let arg = this->cleanArg("MID", arg);

		if (empty(arg)) {
			throw new Exception("Invalid MID");
		}

		let args = preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", arg);
		if (count(args) < 2) {
			throw new Exception("Invalid MID");
		}

		return "substr(" . args[0] . ", (" . args[1] . " - 1), " . args[2] . ")";
	}

	public function processReplace(arg)
	{
		var args;

		let arg = this->cleanArg("REPLACE", arg);

		if (empty(arg)) {
			throw new Exception("Invalid REPLACE");
		}

		let args = preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", arg);
		if (count(args) < 2) {
			throw new Exception("Invalid REPLACE");
		}
		
		return "str_replace(" . args[1] . ", " . args[2] . ", " . args[0] . ")";
	}

	public function processRight(arg)
	{
		var args;

		let arg = this->cleanArg("RIGHT", arg);

		if (empty(arg)) {
			throw new Exception("Invalid RIGHT");
		}

		let args = preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", arg);
		if (count(args) < 1) {
			throw new Exception("Invalid RIGHT");
		}

		return "substr(" . args[0] . ", intval(strlen(" . args[0] . ")) - intval(" . args[1] . "),  intval(" . args[1] . "))";
	}

	public function processRSet(arg)
	{
		var args;

		let arg = this->cleanArg("RSET", arg);

		if (empty(arg)) {
			throw new Exception("Invalid RSET");
		}

		let args = preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", arg);
		if (count(args) < 1) {
			throw new Exception("Invalid RSET");
		}
					
		return "(new KytschBASIC\\Parsers\\Core\Text\\Text())->processPadding(" . args[0] . ", intval(" . args[1] . "))";
	}

	public function processStringSetup(arg)
	{
		var args;

		let arg = this->cleanArg("STRING", arg);

		if (empty(arg)) {
			throw new Exception("Invalid STRING");
		}

		let args = preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", arg);
		if (count(args) < 1) {
			throw new Exception("Invalid STRING");
		}

		return "(new KytschBASIC\\Parsers\\Core\Text\\Text())->processString(" . args[0] . ", intval(" . args[1] . "))";		
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
		var args;

		let arg = this->cleanArg("STRIPLEAD", arg);

		if (empty(arg)) {
			throw new Exception("Invalid STRIPLEAD");
		}

		let args = preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", arg);
		if (count(args) < 1) {
			throw new Exception("Invalid STRIPLEAD");
		}

		return "ltrim(" . args[0] . ", (is_numeric(" . args[1] . ") ? chr(intval(" . args[1] . ")) : " . args[1] . "))";
	}

	public function processStripTrail(arg)
	{
		var args;

		let arg = this->cleanArg("STRIPTRAIL", arg);

		if (empty(arg)) {
			throw new Exception("Invalid STRIPTRAIL");
		}

		let args = preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", arg);
		if (count(args) < 1) {
			throw new Exception("Invalid STRIPTRAIL");
		}

		return "rtrim(" . args[0] . ", (is_numeric(" . args[1] . ") ? chr(intval(" . args[1] . ")) : " . args[1] . "))";
	}

	public function processToString(arg)
	{
		return "(string)" . this->cleanArg("STR", arg);
	}

	public function processUCase(arg)
	{
		return "strtoupper(" . this->cleanArg("UCASE", arg) . ")";
	}

	public function processUnLeft(arg)
	{
		var args;

		let arg = this->cleanArg("UNLEFT", arg);

		if (empty(arg)) {
			throw new Exception("Invalid UNLEFT");
		}

		let args = preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", arg);
		if (count(args) < 1) {
			throw new Exception("Invalid UNLEFT");
		}
		
		return "substr(" . args[0] . ", intval(" . args[1] . ") - 1,  intval(strlen(" . args[0] . ")))";
	}

	public function processUnRight(arg)
	{
		var args;

		let arg = this->cleanArg("UNRIGHT", arg);

		if (empty(arg)) {
			throw new Exception("Invalid UNRIGHT");
		}

		let args = preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", arg);
		if (count(args) < 1) {
			throw new Exception("Invalid UNRIGHT");
		}
		
		return "substr(" . args[0] . ", 0,  intval(strlen(" . args[0] . ")) - intval(" . args[1] . "))";
	}

	public function processVal(arg)
	{
		return "floatval(" . this->cleanArg("VAL", arg) . ")";
	}
}
