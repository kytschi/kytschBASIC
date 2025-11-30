/**
 * Variables parser
 *
 * @package     KytschBASIC\Parsers\Core\Variables
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
namespace KytschBASIC\Parsers\Core;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Libs\Arcade\Parsers\Screen\Display;
use KytschBASIC\Parsers\Core\Input\Form;
use KytschBASIC\Parsers\Core\Maths;
use KytschBASIC\Parsers\Core\Security\Encryption;
use KytschBASIC\Parsers\Core\Session;
use KytschBASIC\Parsers\Core\Text\Text;

class Variables
{
	public types = ["$", "%", "#", "&"];
	public array_types = ["$(", "%(", "#(", "&("];
	public form_variables = ["_GET", "_POST", "_REQUEST", "_FILES"];

	public function args(string line)
	{
		var args = [], arg, vars, str, splits, subvars, cleaned, find, text, display, maths;
		
		let text = new Text();
		let display = new Display();
		let maths = new Maths();

		// Clean any + used for string join.
		let line = preg_replace("/\+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", " . ", line);

		// Grab all vars.
		preg_match_all("/(?<!\\\\)\"(?:\\\\\"|.)*?\"(*SKIP)(*FAIL)|([a-zA-Z0-9_]*)([\$#%&])(?:\()?/", line, vars, PREG_OFFSET_CAPTURE);
		for arg, str in vars[0] {
			if (str[0] == "%") {
				continue;
			}

			let cleaned = "$" . str_replace(this->types, "", str[0]);
			let line = substr_replace(line, cleaned, str[1], strlen(cleaned));
		}
		
		// Grab all form vars.
		preg_match_all("/(?<!\\$)(_GET|_POST|_REQUEST|_FILES)\\(([^)]+)\\)/", line, vars, PREG_OFFSET_CAPTURE);
		// Add some padding to handle the extra char.
		let arg = 0;
		if (vars) {
			for str in vars[0] {
				let arg = "$" . str_replace(")", "]", str_replace("(", "[", str[0]));
				ob_start();
				eval("if (isset(" . arg . ")) {echo " . arg . ";}");
				let find = ob_get_clean();
				if (find) {
					if (substr(line, 0, 1) == "\"") {
						let line = str_replace(str[0], find, line);
					} else {
						let line = str_replace(str[0], "\"" . find . "\"", line);
					}
				} else {
					let line = str_replace(str[0], arg, line);
				}
			}
		}

		// Grab all constants.
		preg_match_all("/_ROOT|_RURL|_URL|_PATH/", line, vars, PREG_OFFSET_CAPTURE);
		for str in vars[0] {
			let line = substr_replace(
				line,
				constant(str[0]),
				str[1],
				strlen(str[0])
			);
		}

		// Grab the _UVARS const if used.
		preg_match_all("/_UVARS\\(([^)]*)\\)/", line, vars, PREG_OFFSET_CAPTURE);
		let arg = 0;
		while (arg != count(vars[0])) {
			let vars[0][arg][0] = str_replace(
				"(" . vars[1][arg][0] . ")",
				"[" . vars[1][arg][0] . "]",
				vars[0][arg][0]
			);

			let line = substr_replace(
				line,
				vars[0][arg][0],
				vars[0][arg][1],
				strlen(vars[0][arg][0])
			);

			let arg += 1;
		}
				
		// Split on comma.
		let splits = this->commaSplit(line);
		for arg in splits {
			// Handle empties.
			if (arg == "") {
				let args[] = "\"\"";
				continue;
			}
			let arg = trim(arg);
						
			//Check to see if its a maths equation.
			let subvars = maths->isEquation(arg);
			if (count(subvars) > 1) {
				/*
				// Replace the pluses if its a string join
				for subvar in subvars {
					if (is_string(subvar) || substr(subvar, strlen(subvar) - 0, 1) == "$") {
						let arg = preg_replace("/\+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*\Z)/", " . ", arg);
						break;
					}
				}*/
				// Replace first unquoted (
				let arg = preg_replace("/\"[^\"]*\"(*SKIP)(*FAIL)|\K\(/", "|||KBBRACKETSTART|||", arg, 1);
				
				// Replace last unquoted ) by reversing the string twice
				let cleaned = strrev(arg);
				let cleaned = preg_replace("/\"[^\"]*\"(*SKIP)(*FAIL)|\K\)/", strrev("|||KBBRACKETEND|||"), cleaned, 1);
				let arg = strrev(cleaned);
				
			}

			//Grab all array elements.
			let cleaned = this->argsArrayElements(arg);
			let cleaned = str_replace("|||KBBRACKETSTART|||", "(", cleaned);
			let cleaned = str_replace("|||KBBRACKETEND|||", ")", cleaned);

			// Process any sub commands, i.e. COUNT()
			if (this->getCommand(cleaned)) {
				let find = text->processValue(cleaned);
				if (find != null) {
					let cleaned = find;
				} else {
					let find = this->processValue(cleaned);
					if (find != null) {
						let cleaned = find;
					} else {
						let find = display->parse(cleaned);
						if (find != null) {
							let cleaned = find;
						} else {
							let find = maths->processValue(cleaned);
							if (find != null) {
								let cleaned = find;
							}
						}
					}
				}
			}

			let args[] = cleaned;
		}

		return args;
	}

	private function argsArrayElements(arg)
	{    
		return preg_replace_callback("/\"[^\"]*\"(*SKIP)(*FAIL)|([()])/", function(splits) {
    		return splits[1] === "(" ? "[" : "]";
		}, arg);
	}

	private function arrayMod(string command, args)
	{
		let args[0] = this->cleanArg(command, args[0]);
		let args = this->commaSplit(args[0]);
						
		if (command == "POP") {
			if (count(args) > 1) {
				return "<?php array_splice(" .
					args[0] . ", " .
					"count(" . args[0] . ") - 1 - intval(" . args[1] . "), " .
					"1); ?>";
			} else {
				return "<?php array_pop(" . args[0] . "); ?>";
			}
		} else {
			if (count(args) > 1) {
				return "<?php array_splice(" .
					args[0] . ",
					intval(" . args[1] . "), " .
					"1); ?>";
			} else {
				return "<?php array_shift(" . args[0] . "); ?>";
			}
		}
	}
	
	public function cleanArg(string command, arg)
	{
		let arg = ltrim(trim(arg), command);		
		
		if (substr(arg, 0, 1) == "[") {
			let arg = ltrim(arg, "[");
			let arg = substr(arg, 0, strlen(arg) - 1);
		}

		let arg = rtrim(ltrim(arg, "("), ")");

		if ((arg != "0" && empty(arg))) {
			throw new Exception("Invalid " . command);
		}

		return arg;
	}

	public function cleanIf(arg)
	{
		return rtrim(rtrim(arg, " THEN"), " THE");
	}

	private function cleanJS(arg)
	{
		return ltrim(arg, "$");
	}

	public function commaSplit(line)
	{
		return preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", line);
	}

	public function dump(output, bool html = false)
	{
		if (html) {
			return "<?php echo \"<pre>\"; var_dump(" . output . "); echo \"</pre>\"; ?>";
		}

		echo "<pre>";
		var_dump(output);
		echo "</pre>";
	}

	public function equalsSplit(line)
	{
		return preg_split("/=(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", line, 2, PREG_SPLIT_NO_EMPTY);
	}

	public function getCommand(string line)
	{
		var strings;

		let line = trim(line);

		if (substr(line, 0, 1) == "\"" || preg_match("/^[a-z]/", line)) {
			return null;
		}

		if (preg_match("/[A-Z]+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", line, strings)) {
			if (strings[0] == "END") {
				return line;
			} elseif (
				strings[0] == "LINE" &&
				substr(line, strlen(line) - strlen("BREAK"), strlen("BREAK")) == "BREAK"
			) {
				return line;
			}

			return strings[0];
		}
	
		return null;
	}

	public function isFormVariable(string arg)
	{
		var type;

		for type in this->form_variables {
			if (substr(arg, 0, strlen(type) + 1) == "$" . type) {
				return true;
			}
		}

		return false;
	}

	public function isVariable(string arg, bool hash = false)
	{
		if (substr(arg, 0, 1) == "\"" || is_numeric(arg)) {
			return false;
		}

		if (in_array(substr(arg, strlen(arg) - 1, 1), this->types)) {
			return true;
		}
		
		// Mostly like the hash.
		if (hash && substr_count(arg, "$") > 1) {
			return false;
		}

		if (substr(arg, 0, 1) == "$" && substr(arg, 0, 1) != "\"") {
			return true;
		}

		/*if (preg_match("/(?<!\")(?:\$\(|%\(|#\(|&\()/", trim(arg))) {
			return true;
		}*/

		if (preg_match("/(?:(|%\(|#\(|&\()/", trim(arg))) {
			return true;
		}
		
		return false;
	}

	public function outputArg(arg, bool is_string = false)
	{
		return (is_string ? "\\\"" : "\\\"\" . ") . arg . (is_string ? "\\\"" : " . \"\\\"");
	}	

	public function parse(string line, string command, array args, bool in_javascript = false)
	{
		switch (command) {
			case "ADEF":
				return this->processDef(line, args, false, true);
			case "ADIM":
				return this->processDim(line, args, true);
			case "BENCHMARK":
				return this->processBenchmark();
			case "DEF":
				return this->processDef(line, args);
			case "DIM":
				return this->processDim(line, args);
			case "DUMP":
				let args[0] = this->cleanArg("DUMP", args[0]);
				return this->dump(args[0], true);
			case "ERASE":
				return this->processErase(args);
			case "LET":
				return this->processDef(line, args, true);
			case "MERGE":
				return this->processMerge(args);
			case "NATSORT":
				return this->processNatSort(args);
			case "NSORT":
				return this->processNSort(args);
			case "POP":
				return this->arrayMod(command, args);
			case "SHIFT":
				return this->arrayMod(command, args);
			case "SHUFFLE":
				return this->processShuffle(args);
			case "SORT":
				return this->processSort(args);
			case "SSORT":
				return this->processSSort(args);
			default:
				return null;
		}
	}

	private function processBenchmark()
	{
		return "<script type=\"text/javascript\">
		if (typeof(kb_start_time) == 'undefined') {
			let kb_start_time = " . constant("START_TIME") .";
			window.onload = () => {
				for (let item of document.getElementsByClassName(\"kb-benchmark\")) {
					item.innerHTML = ((Date.now() - kb_start_time) / 1000).toFixed(3) + \"s\";
				}
			}
		}
		</script>
		<span class=\"kb-benchmark\"></span>";
	}

	private function processContains(arg)
	{
		var splits, args, cleaned;

		let arg = this->cleanIf(arg);

		let splits = this->equalsSplit(arg);
		if (count(splits) > 1) {
			let cleaned = this->cleanArg("CONTAINS", splits[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid CONTAINS");
			}
			let args = this->commaSplit(cleaned);
			return str_replace(splits[1], "in_array(" . args[1] . ", " . args[0] . ")", arg);
		}

		let cleaned = this->cleanArg("CONTAINS", arg);
		if (empty(cleaned)) {
			throw new Exception("Invalid CONTAINS");
		}

		let args = this->commaSplit(cleaned);
		if (count(args) != 2) {
			throw new Exception("Invalid CONTAINS");
		}

		return "in_array(" . args[1] . ", " . args[0] . ")";
	}

	private function processCount(arg)
	{
		var splits, cleaned;

		let arg = this->cleanIf(arg);

		let splits = this->equalsSplit(arg);
		if (count(splits) > 1) {
			let cleaned = this->cleanArg("COUNT", splits[1]);
			if (empty(cleaned)) {
				throw new Exception("Invalid COUNT");
			}
			return str_replace(splits[1], "count(" . cleaned . ")", arg);
		}

		return "count(" . this->cleanArg("COUNT", arg) . ")";
	}

	private function processDateformat(arg)
	{
		var splits, cleaned, args;
		let splits = this->equalsSplit(arg);

		if (count(splits) > 1) {
			let cleaned = this->cleanArg("DATEFORMAT", splits[1]);
			let args = this->commaSplit(cleaned);
			let arg = str_replace(splits[1], "date_format($KBDATE, " . args[1] . ");", arg);
			return "$KBDATE = " . args[0] . "; if(!empty($KBDATE)) {$KBDATE = date_create($KBDATE);" . arg . "}";
		} else {
			let cleaned = this->cleanArg("DATEFORMAT", arg);
			let args = this->commaSplit(cleaned);
			let arg = str_replace(splits[0], "$KBDATE", arg);
			return "<?php $KBDATE = " . args[0] . "; if(!empty($KBDATE)) {$KBDATE = date_create($KBDATE); $KBDATE = date_format($KBDATE, " . args[1] . ");}?>" . arg;
		}
	}

	public function processDef(string line, args, bool let_var = false, bool javascript = false, bool in_javascript = false)
	{
		var arg, output = "<?php ", splits, cleaned;
		
		if (!count(args)) {
			throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
		}
		
		let args = this->equalsSplit(args[0]);
		if (count(args) <= 1) {
			throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
		}

		if (javascript && !in_javascript) {
			let output = "<?= '<script type=\"text/javascript\">";
		}

		// Determine the variable type, int or double.
		preg_match("/[$\%#&](?=(?:(?:[^\"]*\"){2})*[^\"]*$)(?!(?:[^()]*\)))/", line, splits, PREG_OFFSET_CAPTURE);
		if (empty(splits[0][0])) {
			throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
		}

		if (javascript) {
			let args[0] = ltrim(args[0], "$");
			let output .= (let_var ? "" : "var ") . (in_javascript ? "echo \"" . args[0] . " = \"" : args[0] . " = ");
		} else {
			let output .= args[0] . " = ";
		}

		array_shift(args);

		for arg in args {
			switch (splits[0][0]) {
				case "%":
					let cleaned = "intval(" . arg . ")";
					break;
				case "#":
					let cleaned = "(double)" . arg . "";
					break;
				default:
					let cleaned = "\"" . this->outputArg(arg) . "\"";
					break;
			}

			if (javascript && cleaned == "\"\"") {
				let cleaned = "json_encode(" . cleaned . ")";
			}

			if (javascript && cleaned == "") {
				let cleaned = "json_encode(\"\")";
				let arg = "\"\"";
			}

			let output .= (
				javascript ? 
					(in_javascript ? "" : "'") . 
					" . (is_array(" . arg . ") ? json_encode(" . arg. ") : " . cleaned . ")" .
					(in_javascript ? "" : " . ';") :
					arg . ";"
			);
		}

		if (javascript && !in_javascript) {
			let output .= "</script>';";
		}

		return output . " ?>";
	}

	private function processDim(string line, args, bool javascript = false)
	{
		var arg, output = "<?php ", splits, is_array = false, cleaned;

		if (!count(args)) {
			throw new Exception("Invalid DIM");
		}

		preg_match_all("/(?<!\")(?:\$=|%=|#=|&=)/", trim(line), splits);

		if (empty(splits[0][0])) {
			throw new Exception("Invalid DIM");
		}

		if (javascript) {
			let output = "<?= '<script type=\"text/javascript\">";
		}

		let args = this->equalsSplit(args[0]);

		let output .= (javascript ? "var " . ltrim(args[0], "$") : args[0]) . " = ";
		array_shift(args);

		for arg in args {
			if (substr(arg, 0, 1) == "(" || arg == "[]") {
				let is_array = true;
				let output .= "[";
			}

			let arg = ltrim(rtrim(arg, ")"), "(");
			if (arg == "[]") {
				continue;
			}

			switch (splits[0][0]) {
				case "%=":
					let cleaned = "intval(" . arg . ")";
					break;
				case "#=":
					let cleaned = "(double)" . arg . "";
					break;
				default:
					let cleaned = arg;
					break;
			}

			if (javascript && cleaned == "") {
				let cleaned = "json_encode([])";
				let arg = [];
			}

			let output .= (
				javascript ? "' . (is_array(" . arg . ") ? json_encode(" . arg. ") : " . cleaned . ") . ', " :
				arg . ", "
			);
		}

		let output = rtrim(output, ", ");
		if (is_array) {
			let output .= "];";
		}

		if (javascript) {
			let output .= "</script>';";
		}

		return output . " ?>";

	}

	public function setDoubleEquals(arg)
	{
		return preg_replace_callback("/\"[^\"]*\"|<=|>=|=/", function(matches) {
			if (matches[0] === "=") {
				return "==";
			}
			return matches[0];
		}, arg);
	}

	public function processErase(args)
	{
		let args[0] = this->cleanArg("ERASE", args[0]);
		return "<?php unset(" . args[0] . "); ?>";
	}

	public function processMerge(args)
	{	
		let args[0] = this->cleanArg("MERGE", args[0]);
		return "<?php " . args[0] . " = array_merge(" . args[0] . ", " . args[1] . "); ?>";
	}

	public function processNatSort(args)
	{
		let args[0] = this->cleanArg("NATSORT", args[0]);
		return "<?php natsort(" . args[0] . "); " . args[0] . " = array_values(" . args[0] . "); ?>";
	}

	public function processNSort(args)
	{
		return "<?php sort(" . this->cleanArg("NSORT", args[0]) . ", SORT_NUMERIC); ?>";
	}

	public function processReadFile(arg)
	{
		var splits, cleaned, args, output = "";

		let splits = this->equalsSplit(arg);
		if (count(splits) <= 1) {
			throw new Exception("Invalid READFILE");
		}

		let cleaned = this->cleanArg("READFILE", splits[1]);
		let args = this->commaSplit(cleaned);

		let output .= "file_get_contents(";
				
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= args[0];
		} else {
			throw new Exception("Missing the file to read");
		}

		let output .= ")";

		return str_replace(splits[1], output, arg);
	}

	public function processRGBtoHex(arg)
	{
		var splits, cleaned, args;

		let splits = this->equalsSplit(arg);
		if (count(splits) <= 1) {
			throw new Exception("Invalid RGBTOHEX");
		}

		let cleaned = this->cleanArg("RGBTOHEX", splits[1]);
		let args = this->commaSplit(cleaned);

		if (!isset(args[0]) || args[0] == "\"\"") {
			throw new Exception("Invalid R value");
		}
		
		if (!isset(args[1]) || args[1] == "\"\"") {
			throw new Exception("Invalid G value");
		}
		
		if (!isset(args[2]) || args[2] == "\"\"") {
			throw new Exception("Invalid B value");
		}

		return str_replace(
			splits[1],
			"\"#\" . str_pad(dechex(" . args[0] . "), 2, '0', STR_PAD_LEFT)
			. str_pad(dechex(" . args[1] . "), 2, '0', STR_PAD_LEFT)
			. str_pad(dechex(" . args[2] . "), 2, '0', STR_PAD_LEFT)",
			arg
		);
	}

	public function processSessionRead(arg)
	{
		var splits, cleaned;

		let splits = this->equalsSplit(arg);
		if (count(splits) > 1) {
			let cleaned = this->cleanArg("SESSREAD", splits[1]);
			return str_replace(splits[1], "KytschBASIC\\Parsers\\Core\\Session::read(" . trim(cleaned) . ")", arg);
		}

		return "KytschBASIC\\Parsers\\Core\\Session::read(" . trim(this->cleanArg("SESSREAD", arg)) . ")";
	}

	public function processShuffle(args)
	{
		let args[0] = this->cleanArg("SHUFFLE", args[0]);
		return "<?php shuffle(" . args[0] . "); ?>";
	}

	public function processSort(args)
	{
		let args[0] = this->cleanArg("SORT", args[0]);
		return "<?php sort(" . args[0] . "); ?>";
	}

	public function processSplit(arg)
	{
		var splits, cleaned, args, output = "explode(";

		let splits = this->equalsSplit(arg);
		if (count(splits) <= 1) {
			throw new Exception("Invalid SPLIT");
		}

		let cleaned = this->cleanArg("SPLIT", splits[1]);
		let args = this->commaSplit(cleaned);
				
		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let output .= args[1] . ", ";
		} else {
			throw new Exception("Missing the delimiter");
		}

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= args[0];
		} else {
			throw new Exception("Missing the string to split");
		}

		let output .= ");";

		return str_replace(splits[1], output, arg);
	}

	public function processSSort(args)
	{
		let args[0] = this->cleanArg("SSORT", args[0]);
		return "<?php sort(" . args[0] . ", SORT_STRING); ?>";
	}

	public function processTwoDP(arg)
	{
		var splits, cleaned;
		let splits = this->equalsSplit(arg);
		if (count(splits) > 1) {
			let cleaned = this->cleanArg("TWODP", splits[1]);
			return str_replace(splits[1], "number_format(" . cleaned . ", 2, '.', '')", arg);
		}

		return "number_format(" . this->cleanArg("TWODP", arg) . ", 2, '.', '')";
	}

	public function processValidUser(arg)
	{
		var splits, cleaned;

		let splits = this->equalsSplit(arg);
		if (count(splits) > 1) {
			let cleaned = this->cleanArg("VALIDUSER", splits[1]);
			return str_replace(splits[1], "KytschBASIC\\Parsers\\Core\\Session::read(" . cleaned . ")", arg);
		}

		return "KytschBASIC\\Parsers\\Core\\Session::read(" . this->cleanArg("VALIDUSER", arg) . ")";
	}

	public function processValue(arg)
	{
		switch (this->getCommand(arg)) {
			case "CONTAINS":
				return this->processContains(arg);
			case "COUNT":
				return this->processCount(arg);
			case "DATEFORMAT":
				return this->processDateformat(arg);
			case "HASHVERIFY":
				return (new Encryption())->processHashVerify(arg);
			case "HASH":
				return (new Encryption())->processHash(arg);
			case "READFILE":
				return this->processReadFile(arg);
			case "RGBTOHEX":
				return this->processRGBtoHex(arg);
			case "VALIDUSER":
				return this->processValidUser(arg);
			case "SANITISE":
				return this->processSanitise(arg);
			case "SESSREAD":
				return this->processSessionRead(arg);
			case "SPLIT":
				return this->processSplit(arg);
			case "TWODP":
				return this->processTwoDP(arg);
			case "UUID":
				return (new Encryption())->processUUID(arg);
			case "VALIDCAPTCHA":				
				return str_replace("VALIDCAPTCHA", (new Form())->validateCaptcha(), arg);
			default:
				return null;
		}
	}

	public function processSanitise(arg)
    {
        var checks = [
            "\\":"&#92;",
            "’": "&#39;"
        ],
        check, replace, splits, cleaned;

		for check, replace in checks {
			let arg = str_replace(check, replace, arg);
		}

		let splits = this->equalsSplit(arg);
		if (count(splits) > 1) {
			let cleaned = this->cleanArg("SANITISE", splits[1]);
			return str_replace(splits[1], "filter_var(rawurldecode(" . cleaned . "), FILTER_SANITIZE_FULL_SPECIAL_CHARS)", arg);
		}
        
		return "filter_var(rawurldecode(" . arg . "), FILTER_SANITIZE_FULL_SPECIAL_CHARS);";
    }
}
