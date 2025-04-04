/**
 * Variables parser
 *
 * @package     KytschBASIC\Parsers\Core\Variables
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
use KytschBASIC\Libs\Arcade\Parsers\Screen\Display;
use KytschBASIC\Parsers\Core\Function\Misc;
use KytschBASIC\Parsers\Core\Maths;
use KytschBASIC\Parsers\Core\Text\Text;

class Variables
{
	public types = ["$", "%", "#", "&"];
	public array_types = ["$(", "%(", "#(", "&("];
	public form_variables = ["_GET", "_POST", "_REQUEST"];

	public function args(string line)
	{
		var args = [], arg, vars, str, splits, subvars, cleaned, find, text, display;

		let text = new Text();
		let display = new Display();

		// Clean any + used for string join.
		let line = preg_replace("/\+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", ".", line);

		//Grab all vars.
		preg_match_all("/\\b[\\w.-]*[$%#&](?!\\w)/u", line, vars);
		for str in vars[0] {
			let line = str_replace(str, "$" . str_replace(this->types, "", str), line);
		}

		//Grab all form vars.
		preg_match_all("/(_GET|_POST|_REQUEST)(?=(?:[^\"']|[\"'][^\"']*[\"'])*$)/", line, vars, PREG_OFFSET_CAPTURE);
		for str in vars[1] {
			let line = substr_replace(line, "$" . str[0], str[1], strlen(str[0]));
		}

		//Grab all constants.
		preg_match_all("/_ROOT|_RURL|_URL|_PATH/", line, vars, PREG_OFFSET_CAPTURE);
		for str in vars[0] {
			let line = substr_replace(line, constant(str[0]), str[1], strlen(str[0]));
		}
				
		// Split on the equals.
		let splits = preg_split("/(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?<!=)=/", line, 2, PREG_SPLIT_NO_EMPTY);
		for arg in splits {
			let arg = trim(arg);
			
			// Split on comma.
			let vars = preg_split("/,\s*(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?=(?:[^()]*\([^()]*\))*[^()]*$)/", arg);
			for str in vars {
				let str = trim(str);

				// Handle empties.
				if (str == "\"\"") {
					let str = "";
				}
				
				//Check to see if its a maths equation.
				let subvars = preg_split("/([+\-\/])(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", str, 0, 2);
				if (count(subvars) > 1) {
					let args[] = str;
					continue;
				}

				//Grab all array elements.
				let cleaned = this->argsArrayElements(str);

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
							}
						}
					}
				}

				let args[] = cleaned;
			}
		}

		return args;
	}

	private function argsArrayElements(arg)
	{
		var splits, str, cleaned;
		
		preg_match_all("/\((?:[^()\"]+|\"(?:\\\\.|[^\\\\\"])*\")*\)/", arg, splits, PREG_OFFSET_CAPTURE);
				
		if (empty(splits[0])) {
			return arg;
		}
						
		for str in splits[0] {
			let cleaned = rtrim(ltrim(str[0], "("), ")");
			let arg = substr_replace(arg, "[" . cleaned . "]", str[1], strlen(str[0]));
		}
		
		return this->argsArrayElements(arg);
	}

	private function arrayMod(string command, array args)
	{
		let args[0] = this->cleanArg(command, args[0]);
				
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

	private function cleanJS(arg)
	{
		return ltrim(arg, "$");
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

	public function getCommand(string line)
	{
		var strings;

		if (substr(line, 0, 1) == "\"" || preg_match("/^[a-z]/", line)) {
			return null;
		}

		if (preg_match("/[A-Z]+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", line, strings)) {
			if (strings[0] == "END") {
				return line;
			} elseif (strings[0] == "LINE" && substr(line, strlen(line) - strlen("BREAK"), strlen("BREAK")) == "BREAK") {
				return line;
			}

			return strings[0];
		}
	
		return null;
	}

	public function isVariable(string arg)
	{
		if (substr(arg, 0, 1) == "\"" || is_numeric(arg)) {
			return false;
		}

		if (in_array(substr(arg, strlen(arg) - 1, 1), this->types)) {
			return true;
		}
		
		if (preg_match("/(?<!\")(?:\$\(|%\(|#\(|&\()/", trim(arg))) {
			return true;
		}
		
		return false;
	}

	public function outputArg(arg, bool is_string = false)
	{
		return (is_string ? "\\\"" : "\\\"\" . ") . arg . (is_string ? "\\\"" : " . \"\\\"");
	}	
/*
	public function outputForJavascript(value)
	{
		if (is_array(value) || is_object(value)) {
			if (is_array(value)) {
				let value = array_values(value);
			}
			echo json_encode(value);
		} else {
			echo value;
		}		
	}
	*/
	public function parse(string line, string command, array args)
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

	public function processValue(arg)
	{		
		switch (this->getCommand(arg)) {
			case "TWODP":
				return this->processTwoDP(arg);
			case "COUNT":
				return this->processCount(arg);
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

	private function processCount(arg)
	{
		let arg = this->cleanArg("COUNT", arg);
		return "count(" . arg . ")";
	}

	private function processDef(string line, array args, bool let_var = false, bool javascript = false)
	{
		var arg, output = "<?php ", splits, cleaned;

		if (count(args) <= 1) {
			throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
		}

		let splits = explode("=", line, 2);
		if (count(splits) <= 1) {
			throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
		}

		if (javascript) {
			let output = "<?= '<script type=\"text/javascript\">";
		}

		preg_match("/[$\%#&](?=(?:(?:[^\"]*\"){2})*[^\"]*$)(?!(?:[^()]*\)))/", splits[0], splits, PREG_OFFSET_CAPTURE);
		if (empty(splits[0][0])) {
			throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
		}

		let output .= (javascript ? "var " . ltrim(args[0], "$") : args[0]) . " = ";
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
					let cleaned = arg;
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
				javascript ? "' . (is_array(" . arg . ") ? json_encode(" . arg. ") : " . cleaned . ") . ';" :
				arg . ";"
			);
		}

		if (javascript) {
			let output .= "</script>';";
		}

		return output . " ?>";
	}

	private function processDim(string line, array args, bool javascript = false)
	{
		var arg, output = "<?php ", splits, is_array = false, cleaned;

		if (count(args) < 1) {
			throw new Exception("Invalid DIM");
		}

		preg_match_all("/(?<!\")(?:\$=|%=|#=|&=)/", trim(line), splits);

		if (empty(splits[0][0])) {
			throw new Exception("Invalid DIM");
		}

		if (javascript) {
			let output = "<?= '<script type=\"text/javascript\">";
		}

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

	public function processSSort(args)
	{
		let args[0] = this->cleanArg("SSORT", args[0]);
		return "<?php sort(" . args[0] . ", SORT_STRING); ?>";
	}

	public function processTwoDP(arg)
	{
		let arg = this->cleanArg("TWODP", arg);
		return "number_format(" . arg . ", 2, '.', '')";
	}
}
