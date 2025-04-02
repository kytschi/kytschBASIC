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
		var args = [], arg, vars, str, splits, subvars, cleaned, find, text;

		let text = new Text();

		// Clean any + used for string join.
		let line = preg_replace("/\+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", ".", line);

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
				
		// Split on the equals.
		let splits = preg_split("/(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?<!=)=/", line, 2, PREG_SPLIT_NO_EMPTY);
		for arg in splits {
			let arg = trim(arg);

			// Split on comma.
			let vars = preg_split("/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", arg);
			for str in vars {
				let str = trim(str);

				//Check to see if its a maths equation.
				let subvars = preg_split("/\*|\+|\<-|\-|\>=|\>|\<=|\<|\==|\//", str, 0, 2);
				if (count(subvars) > 1) {
					let args[] = str;
					continue;
				}
				
				//Grab all array elements.
				let cleaned = this->argsArrayElements(str);
				
				if (this->getCommand(cleaned)) {
					let find = text->processValue(cleaned);
					if (find != null) {
						let cleaned = find;
					} else {
						let find = this->processValue(cleaned);
						if (find != null) {
							let cleaned = find;
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
/*
	private function arrayMod(args, bool pop = true)
	{
		var value;

		let args = this->args(this->cleanArg(pop ? "POP" : "SHIFT" , args));
		
		let value = this->cleanVarOnly(args[0]);
		
		if (pop) {
			if (count(args) > 1) {
				return "<?php array_splice(" .
					value . ", " .
					"count(" . value . ") - 1 - intval(" . this->outputArg(args[1], false) . "), " .
					"1); ?>";
			} else {
				return "<?php array_pop(" . value . "); ?>";
			}
		} else {
			if (count(args) > 1) {
				return "<?php array_splice(" .
					value . ",
					intval(" . this->outputArg(args[1], false) . "), " .
					"1); ?>";
			} else {
				return "<?php array_shift(" . value . "); ?>";
			}
		}
	}
	*/
	public function cleanArg(string command, arg)
	{
		let arg = rtrim(
			rtrim(
				str_replace(
					[
						command . "(",
						command . "["
					],
					"",
					arg
				),
				"]"
			),
		")");

		if ((arg != "0" && empty(arg))) {
			throw new Exception("Invalid " . command);
		}

		return arg;
	}
/*
	public function constants(string line)
	{
		var con, constants = [
			"_ROOT",
			"_RURL",
			"_URL",
			"_PATH"
		];

		for con in constants {
			let line = str_replace(con, constant(con), line);
		}

		return line;
	}
*/
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
			} elseif (substr(strings[0], strlen(strings[0]) - strlen("BREAK"), strlen("BREAK")) == "BREAK") {
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
			/*case "ADEF":
				return this->processDef(args, false, true);
			case "ADIM":
				return this->processDim(args, true);*/
			case "BENCHMARK":
				return this->processBenchmark();
			case "DEF":
				return this->processDef(line, args);
			case "DIM":
				return this->processDim(line, args);
			case "DUMP":
				if (strpos(line, "DUMP(") !== false) {
					let args[0] = rtrim(ltrim(args[0], "["), "]");
				}
				return this->dump(args[0], true);
			case "LET":
				return this->processDef(line, args, true);
			/*case "MERGE":
				return this->processMerge(command, args);
			case "NATSORT":
				return this->processNatSort(command);
			case "NSORT":
				return this->processNSort(command);
			case "POP":
				return this->arrayMod(command . args);
			case "SHIFT":
				return this->arrayMod(command . args, false);
			case "SHUFFLE":
				return this->processShuffle(command);
			case "SORT":
				return this->processSort(command);
			case "SSORT":
				return this->processSSort(command);*/
			default:
				return null;
		}
	}

	public function processValue(arg)
	{		
		switch (this->getCommand(arg)) {
			case "TWODP":
				return this->processTwoDP(arg);
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

	private function processDef(string line, array args, bool let_var = false, bool javascript = false)
	{
		var arg, key, output = "<?php ", splits;

		if (count(args) < 1) {
			throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
		}

		preg_match_all("/(?<!\")(?:\$=|%=|#=|&=|\$\(\)=|%\(\)=|#\(\)=|&\(\)=)/", trim(line), splits);
		
		if (empty(splits[0][0])) {
			throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
		}

		for key, arg in args {
			if (!key) {
				let output .= arg . " = ";
			} else {
				switch (splits[0][0]) {
					case "%()=":
					case "%=":
						let output .= "intval(" . arg . ");";
						break;
					case "#()=":
					case "#=":
						let output .= "(double)" . arg . ";";
						break;
					default:
						let output .= arg . ";";
						break;
				}
			}
		}

		return output . " ?>";
	}

	private function processDim(string line, array args, bool javascript = false)
	{
		var arg, key, output = "<?php ", splits;

		if (count(args) < 1) {
			throw new Exception("Invalid DIM");
		}

		preg_match_all("/(?<!\")(?:\$=|%=|#=|&=)/", trim(line), splits);

		if (empty(splits[0][0])) {
			throw new Exception("Invalid DIM");
		}

		for key, arg in args {
			if (!key) {
				let output .= arg . " = array(";
			} else {
				let arg = ltrim(rtrim(arg, ")"), "(");

				if (arg == "[]") {
					let arg = "";
				}

				if (empty(arg)) {
					let output .= arg . ", ";
				} else {
					switch (splits[0][0]) {
						case "%=":
							let output .= "intval(" . arg . "), ";
							break;
						case "#=":
							let output .= "(double)" . arg . ", ";
							break;
						default:
							let output .= arg . ", ";
							break;
					}
				}
			}
		}

		return rtrim(output, ", ") . "); ?>";

	}
/*
	public function processMerge(command, args)
	{
		let command = command . args;
		let args = this->args(this->cleanArg("MERGE", command));
		let args[0] = this->cleanVarOnly(args[0], false, false);
		
		return "<?php " . args[0] . " = array_merge(" . args[0] . ", " . this->cleanVarOnly(args[1], false, false) . "); ?>";
	}

	public function processNatSort(args)
	{
		var cleaned;

		let args = this->args(this->cleanArg("NATSORT", args));
		let cleaned = this->cleanVarOnly(args[0], false);

		return "<?php natsort(" . cleaned . "); " . cleaned . " = array_values(" . cleaned . "); ?>";
	}

	public function processNSort(args)
	{
		let args = this->args(this->cleanArg("NSORT", args));
		return "<?php sort(" . this->cleanVarOnly(args[0]) . ", SORT_NUMERIC); ?>";
	}

	public function processShuffle(args)
	{
		let args = this->args(this->cleanArg("SHUFFLE", args));
		return "<?php shuffle(" . this->cleanVarOnly(args[0]) . "); ?>";
	}

	public function processSort(args)
	{
		let args = this->args(this->cleanArg("SORT", args));
		return "<?php sort(" . this->cleanVarOnly(args[0]) . "); ?>";
	}

	public function processSSort(args)
	{
		let args = this->args(this->cleanArg("SSORT", args));
		return "<?php sort(" . this->cleanVarOnly(args[0]) . ", SORT_STRING); ?>";
	}
*/
	public function processTwoDP(arg)
	{
		let arg = this->cleanArg("TWODP", arg);
		return "number_format(" . arg . ", 2, '.', '')";
	}
/*
	private function setArrayElement(string line, splits, string type, bool let_var = false)
	{
		var output = "<?php $", vars, args, arg;
		this->dump(splits[0]);
		let args = this->args(splits[0]);
		this->dump(args);

		

		return output . "; ?>";
	}*/
}
