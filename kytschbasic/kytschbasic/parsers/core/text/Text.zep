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

use KytschBASIC\Parsers\Core\Command;

class Text extends Command
{
	public function parse(string command, string args)
	{
		if (command == "PRINT") {
			return this->processPrint(args);
		} elseif (command == "END SWRITE") {
			return "</p>";
		} elseif (command == "SWRITE") {
			return this->processSWrite(args);
		} elseif (command == "LINE BREAK") {
			return "<br/>";
		}

		return null;
	}

	private function processPrint(args)
	{
		var value="", output = "<?= \"<span";

		let args = this->args(args);

		let value = args[0];

		if (substr(value, 0, 1) == "{") {
			let value = this->outputArg(value, false, true);
		}
		
		if (isset(args[1])) {
			let output .= " class=" . this->outputArg(args[1]);
		}

		if (isset(args[2]) && !empty(args[2])) {
			let output .= " id=" . this->outputArg(args[2]);
		} else {
			let output .= " id=" . this->outputArg(this->genID("kb-span"));
		}

		if (isset(args[3])) {
			let output .= " " . str_replace(
				"\"",
				"\\\"",
				args[3]
			);
		}
		
		return output . ">\" . " . value . " . \"</span>\";?>";
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

	private function processSWrite(args)
	{
		var params="";

		let args = this->args(args);
		
		if (isset(args[0]) && !empty(args[0])) {
			let params .= " class=" . this->outputArg(args[0]);
		}

		if (isset(args[1]) && !empty(args[1])) {
			let params .= " id=" . this->outputArg(args[1]);
		} else {
			let params .= " id=" . this->outputArg(this->genID("kb-span"));
		}
		
		return "<?= \"<p" . params . ">\"; ?>";
	}

	public function processValue(args)
	{
		if (is_string(args)) {
			let args = [args];
		}
		
		switch (this->getCommand(args[0])) {
			case "ASC":
				return this->processAsc(args);
			case "CENTRE":
				return this->processCentre(args);
			case "CHR":
				return this->processChr(args);
			case "COUNT":
				return this->processCount(args);
			case "INSTR":
				return this->processInstr(args);
			case "INT":
				return this->processInt(args);
			case "LCASE":
				return this->processLCase(args);
			case "LEFT":
				return this->processLeft(args);
			case "LEN":
				return this->processLen(args);
			case "LSET":
				return this->processLSet(args);
			case "MID":
				return this->processMid(args);
			case "REPLACE":
				return this->processReplace(args);
			case "RSET":
				return this->processRSet(args);
			case "RIGHT":
				return this->processRight(args);
			case "STRING":
				return this->processString(args);
			case "STRIPLEAD":
				return this->processStripLead(args);
			case "STRIPTRAIL":
				return this->processStripTrail(args);
			case "STR":
				return this->processToString(args);
			case "UCASE":
				return this->processUCase(args);
			case "UNLEFT":
				return this->processUnLeft(args);
			case "UNRIGHT":
				return this->processUnRight(args);
			case "VAL":
				return this->processVal(args);
			default:
				return null;
		}
	}

	public function processAsc(args)
	{
		let args[0] = this->cleanArg("ASC", args[0]);
		
		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid ASC");
		}

		let args[0] = this->clean(
			args[0],
			this->isVariable(args[0])
		);

		return "ord(" . this->outputArg(args[0], false, true) . ")";
	}

	public function processCentre(args)
	{
		var converted, length = 1;

		let args[0] = trim(str_replace("CENTRE", "", args[0]));
		let args = this->args(args[0]);
		
		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid CENTRE");
		}

		let converted = args[0];
				
		if (isset(args[1])) {
			if (is_numeric(args[1])) {
				let length = intval(args[1]);
			}
		}
		return "substr(" .
			this->outputArg(converted, false, true) . ", intval(strlen(" .
			this->outputArg(converted, false, true) . ") / 2) - 1, intval(" . length . "))";
	}

	public function processChr(args)
	{
		let args[0] = trim(str_replace("CHR", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid CHR");
		}

		return "chr(intval(" . this->outputArg(args[0], false, true) . "))";
	}

	public function processCount(args)
	{
		let args[0] = trim(str_replace("COUNT", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid COUNT");
		}

		return "count($" . str_replace(this->types, "", args[0]) . ")";
	}

	public function processInstr(args)
	{
		let args[0] = trim(str_replace("INSTR", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid INSTR");
		}
				
		var haystack = "", needle = "\"\"";
		
		let haystack = this->outputArg(args[0], false, true);
		array_shift(args);

		if (isset(args[0])) {
			let needle = this->outputArg(args[0], false, true);
		}

		return "strpos(" . haystack . ", " . needle . ")";
	}

	public function processInt(args)
	{
		let args[0] = trim(str_replace("INT", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid INT");
		}

		return "intval(" . this->outputArg(args[0], false, true) . ")";
	}

	public function processLCase(args)
	{
		let args[0] = trim(str_replace("LCASE", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid LCASE");
		}
		
		return "strtolower(" . this->outputArg(args[0], false, true) . ")";
	}

	public function processLeft(args)
	{
		var converted, length = 1;

		let args[0] = trim(str_replace("LEFT", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid LEFT");
		}

		let converted = args[0];
		array_shift(args);
		
		if (isset(args[0])) {
			if (is_numeric(args[0])) {
				let length = intval(args[0]);
			}
		}
		return "substr(\"" . converted . "\", 0,  intval(" . length . "))";
	}

	public function processLen(args)
	{
		let args[0] = trim(str_replace("LEN", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid LEN");
		}

		return "strlen(" . this->outputArg(args[0], false, true) . ")";
	}

	public function processLSet(args)
	{
		var converted, length = 1;

		let args[0] = trim(str_replace("LSET", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid LSET");
		}

		let converted = this->outputArg(args[0], false, true);
		array_shift(args);
		
		if (isset(args[0])) {
			if (is_numeric(args[0])) {
				let length = intval(args[0]);
			}
		}
					
		return "(new KytschBASIC\\Parsers\\Core\Text\\Text())->processPadding(" . converted . ", intval(" . length . "), 'left')";
	}

	public function processMid(args)
	{
		var converted, start = 0, end = 1;

		let args[0] = trim(str_replace("MID", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid MID");
		}
					
		let converted = args[0];
		array_shift(args);
		
		if (isset(args[0])) {
			if (is_numeric(args[0])) {
				let start = intval(args[0]);
			}
		}

		if (isset(args[1])) {
			if (is_numeric(args[1])) {
				let end = intval(args[1]);
				unset(args[1]);
			}
		}

		return "substr(\"" . converted . "\", " . (start - 1) . ", " . end . ")";
	}

	public function processReplace(args)
	{
		var find = "\"\"", replace = "\"\"", converted = "\"\"";

		let args[0] = trim(str_replace("REPLACE", "", args[0]));
			
		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid REPLACE");
		}

		let args = this->args(args[0]);

		if (empty(args)) {
			throw new \Exception("Invalid REPLACE");
		}
		
		let converted = this->outputArg(args[0], false, true);
		array_shift(args);
		
		if (isset(args[0])) {
			let find = this->outputArg(args[0], false, true);
			array_shift(args);
		}

		if (isset(args[0])) {
			let replace = this->outputArg(args[0], false, true);
		}
		
		return "str_replace(" . find . ", " . replace . ", " . converted . ")";
	}

	public function processRight(args)
	{
		var converted, length = 1;

		let args[0] = trim(str_replace("RIGHT", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid RIGHT");
		}

		let converted = this->outputArg(args[0], false, true);
		array_shift(args);
		
		if (isset(args[0])) {
			if (is_numeric(args[0])) {
				let length = intval(args[0]);
			}
		}
		return "substr(" . converted . ", intval(strlen(" . converted . ")) - intval(" . length . "),  intval(" . length . "))";
	}

	public function processRSet(args)
	{
		var converted, length = 1;

		let args[0] = trim(str_replace("RSET", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid RSET");
		}

		let converted = this->outputArg(args[0], false, true);
		array_shift(args);
		
		if (isset(args[0])) {
			if (is_numeric(args[0])) {
				let length = intval(args[0]);
			}
		}
					
		return "(new KytschBASIC\\Parsers\\Core\Text\\Text())->processPadding(" . converted . ", intval(" . length . "))";
	}

	public function processString(args)
	{
		var converted, length = 1, value = "";

		let args[0] = trim(str_replace("STRING", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid STRING");
		}
					
		let converted = this->outputArg(args[0], false, true);
		array_shift(args);
		
		if (isset(args[0])) {
			if (is_numeric(args[0])) {
				let length = intval(args[0]);
			}
		}

		while length {
			let value .= converted;
			let length -= 1;
		}

		return value;
	}

	public function processStripLead(args)
	{
		var converted, value = "", strip_char = "";

		let args[0] = trim(str_replace("STRIPLEAD", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid STRIPLEAD");
		}
					
		let converted = this->outputArg(args[0], false, true);
		array_shift(args);
				
		if (isset(args[0])) {
			let value = args[0];
			let strip_char = "is_numeric(\"" . value . "\") ? chr(intval(\"" . value . "\")) : \"" . value . "\"";
		}

		return "ltrim(" . converted . ", " . strip_char . ")";
	}

	public function processStripTrail(args)
	{
		var converted, value = "", strip_char = "";

		let args[0] = trim(str_replace("STRIPTRAIL", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid STRIPTRAIL");
		}
					
		let converted = this->outputArg(args[0], false, true);
		array_shift(args);
		
		if (isset(args[0])) {
			let value = args[0];
			let strip_char = "is_numeric(\"" . value . "\") ? chr(intval(\"" . value . "\")) : \"" . value . "\"";
		}

		return "rtrim(" . converted . ", " . strip_char . ")";
	}

	public function processToString(args)
	{
		let args[0] = trim(str_replace("STR", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid STR");
		}

		return "(string)" . this->outputArg(args[0], false, true);
	}

	public function processUCase(args)
	{
		let args[0] = trim(str_replace("UCASE", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid UCASE");
		}

		return "strtoupper(" . this->outputArg(args[0], false, true) . ")";
	}

	public function processUnLeft(args)
	{
		var converted, length = 1;

		let args[0] = trim(str_replace("UNLEFT", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid UNLEFT");
		}

		let converted = this->outputArg(args[0], false, true);
		array_shift(args);
		
		if (isset(args[0])) {
			if (is_numeric(args[0])) {
				let length = intval(args[0]);
			}
		}

		return "substr(" . converted . ", intval(" . length . ") - 1,  intval(strlen(" . converted . ")))";
	}

	public function processUnRight(args)
	{
		var converted, length = 1;

		let args[0] = trim(str_replace("UNRIGHT", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid UNRIGHT");
		}

		let converted = this->outputArg(args[0], false, true);
		array_shift(args);
		
		if (isset(args[0])) {
			if (is_numeric(args[0])) {
				let length = intval(args[0]);
			}
		}
		return "substr(" . converted . ", 0,  intval(strlen(" . converted . ")) - intval(" . length . "))";
	}

	public function processVal(args)
	{
		let args[0] = trim(str_replace("VAL", "", args[0]));

		if (args[0] != "0" && empty(args[0])) {
			throw new \Exception("Invalid VAL");
		}

		return "floatval(" . this->outputArg(args[0], false, true) . ")";
	}
}
