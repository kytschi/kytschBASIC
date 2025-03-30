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
		var args = [], arg, vars, str, cleaned, splits, text, value;

		let text = new Text();
		
		if (empty(line)) {
			return [];
		}

		if (substr(line, 0, 1) == "(") {
			return [line];
		}

		let splits = preg_split("/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)(?![^()]*\))/", line);
						
		for arg in splits {
			let arg = trim(arg);

			if (empty(arg)) {
				let args[] = arg;
				continue;
			}
			
			let vars = preg_split("/\+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", arg);
			
			if (count(vars) > 1) {
				let cleaned = "";

				for str in vars {
					let str = trim(str);
					let value = text->processValue(str);
					if (value != null) {
						let cleaned .= value . " . ";
					} else {
						let cleaned .= this->clean(
							str,
							this->isVariable(str),
							[str]
						) . " . ";
					}
				}

				let args[] = rtrim(cleaned, " . ");
			} else {				
				if (substr(arg, 0, 1) == "\"" || is_numeric(arg)) {
					let args[] = arg;	
				} else {
					let value = text->processValue(arg);
					if (value != null) {
						let args[] = value;
					} else {
						let vars = preg_split("/(?<!\")(?:\$\(|%\(|#\(|&\()/", rtrim(arg, ")"));
						if (count(vars) > 1) {
							if (!is_numeric(vars[1]) && substr(vars[1], 0, 1) != "\"") {
								let arg = str_replace(
									vars[1],
									"$" . str_replace(this->types, "", vars[1]),
									arg
								);
							}
	
							let arg = str_replace("(", "[", str_replace(")", "]", arg));
	
							let arg = str_replace(
								[vars[0] . "$", vars[0] . "%", vars[0] . "#", vars[0] . "&"],
								"$" . str_replace(this->types, "", vars[0]),
								arg
							);
							
							let args[] = arg;
						} else {
							let args[] = this->clean(
								arg,
								this->isVariable(arg),
								[arg]
							);
						}						
					}
				}
			}
		}

		return args;
	}

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

	public function clean(string line, bool inline_string = true, args = null)
	{
		var arg, value = null, maths_controller, vars;

		let maths_controller = new Maths();

		if (!args) {
			let args = preg_split("/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", trim(line));
		}
		
		let line = "";
		
		for arg in args {
			let arg = trim(arg);

			let value = maths_controller->processValue(arg);
			if (value !== null) {
				let line .= value;
			} else {
				let value = Display::parse(arg);

				if (value !== null) {
					let line .= value;
				} else {
					if (this->isFormVariable(arg)) {
						let inline_string = false;
						let arg = "$" . arg;
					}

					if (substr(arg, strlen(arg) - 1, 1) == ")") {
						let vars = preg_split("/(?<!\")(?:\$\(|%\(|#\(|&\()/", rtrim(arg, ")"));
						
						if (!is_numeric(vars[1]) && substr(vars[1], 0, 1) != "\"") {
							let arg = str_replace(
								vars[1],
								"$" . str_replace(this->types, "", vars[1]),
								arg
							);
						}

						let arg = str_replace("(", "[", str_replace(")", "]", arg));

						let arg = str_replace(
							[vars[0] . "$", vars[0] . "%", vars[0] . "#", vars[0] . "&"],
							"$" . str_replace(this->types, "", vars[0]),
							arg
						);

						let line .= inline_string ? this->outputArg("{" . arg . "}", false) : arg;
					} else {
						let line .= inline_string ? this->outputArg("{$" . str_replace(this->types, "", arg) . "}", false) : arg;
					}
				}
			}
		}
		
		return (value !== null) ? maths_controller->equation(line) : line;
	}
	
	public function cleanArg(string command, arg)
	{
		let arg = preg_replace("/\)$/", "", trim(str_replace(command . "(", "", arg)));

		if ((arg != "0" && empty(arg)) || substr(arg, 0, strlen(command)) == command) {
			throw new Exception("Invalid " . arg);
		}

		return arg;
	}

	private function cleanArray(arg)
	{
		return str_replace("(", "[", str_replace(")", "]", arg));
	}

	public function cleanVarOnly(arg, bool clean = true, bool types = true)
	{
		var search;
		
		let search = types ? this->types : [];

		let search[] = "\"{";
		let search[] = "}\"";

		return (types ? "$" : "") . str_replace(
			")",
			"]",
			str_replace(
				"(",
				"[",
				str_replace(
					search,
					"",
					(clean ? this->clean(arg, false) : arg)
				)
			)
		);
	}

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

	private function createArray(string line, splits, bool javascript = false)
	{
		var output = "<?php $", converted = "";

		if (javascript) {
			let output = "<script type=\"text/javascript\">\nvar ";
		}

		if (count(splits) > 1) {
			let output .= splits[0] . " = ";
			
			if (this->isVariable(line)) {
				let converted = this->clean(
					splits[1],
					this->isVariable(line)
				);
			} elseif (substr(line, strlen(line) - 2, 1) == "\")") {
				let converted = str_replace(")", "]", str_replace("(", "[", splits[1])) . ")";
			} else {
				let converted = "array(" . str_replace(["(", ")"], "", splits[1]) . ")";
			}

			if (substr(converted, 0, 3) == "\"{$") {
				let converted = this->cleanVarOnly(converted, false);
			}

			if (javascript) {
				let output .= "<?= (new KytschBASIC\\Parsers\\Core\\Variables())->outputForJavascript(" . converted . "); ?>";
			} else {
				let output .= converted;
			}

			return output . (javascript ? "\n</script>\n" : "; ?>");
		} else {
			throw new Exception("Invalid DIM");
		}		
	}

	private function createElement(string line, splits, string type)
	{
		var vars, output = "", cleaned;
		
		if (substr(line, strlen(line) - 1, 1) == ")") {
			let vars = preg_split("/(?<!\")(?:\$\(|%\(|#\(|&\()/", rtrim(splits[1], ")"));

			let output .= "$" . vars[0] . "[";

			if (is_numeric(vars[1])) {
				let output .= vars[1];
			} else {
				let cleaned = this->clean(
					vars[1],
					this->isVariable(vars[1])
				);

				if (substr(cleaned, 0, 3) == "\"{$") {
					let cleaned = this->cleanVarOnly(cleaned, false);
				}

				let output .= cleaned;
			}

			let output .= "]";
		} else {
			let vars = this->args(splits[1]);
			if (count(vars) == 1) {
				if (substr(vars[0], 0, 3) == "\"{$") {
					let vars[0] = this->cleanVarOnly(vars[0], false);
				}
			}
						
			if (type == "%(") {
				let vars[0] = "intval(" . vars[0] . ")";
			} elseif (type == "#(") {
				let vars[0] = "(double)" . vars[0] . "";
			}

			let output .= vars[0];
		}

		return output;
	}

	private function createInt(string line, splits, string var_type = "", bool javascript = false)
	{
		var output = "<?php $", converted = "";

		if (javascript) {
			let output = "<script type=\"text/javascript\">\nvar ";
		}

		array_shift(splits);

		let output .= line . var_type . " = ";

		if (is_numeric(splits[0])) {
			let converted = splits[0];
		} else {
			let converted = (new Misc())->processFunction(splits);
			let converted = (new Maths())->equation(converted);
		}

		if (javascript) {
			let converted = "\"<?= (new KytschBASIC\\Parsers\\Core\\Variables())->outputForJavascript(" . converted . "); ?>\"";
		}

		return output . (javascript ? "parseInt(" . converted . ");\n</script>\n" : "intval(" . converted . "); ?>");
	}

	private function createDouble(string line, splits, string var_type = "")
	{
		var output = "<?php $";

		array_shift(splits);

		let output .= line . var_type . " = (double)";

		if (is_numeric(splits[0])) {
			let output .= splits[0];
		} else {
			let output .= (new Misc())->processFunction(splits);
		}

		return output . "; ?>";
	}

	private function createString(string line, splits, string var_type = "", bool javascript = false)
	{
		var strings, str, item, output = "<?php $", cleaned = "", vars, converted = "";

		if (javascript) {
			let output = "<script type=\"text/javascript\">\nvar ";
		}

		let output .= splits[0] . var_type . " = ";

		let strings = preg_split("/\+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", splits[1]);
		
		for str in strings {
			let str = trim(str);
			
			preg_match_all("/(?<!\")(?:\$\(|%\(|#\(|&\()/", str, vars);
									
			if (!empty(vars[0])) {
				let converted = "";
				for item in vars[0] {
					let converted .= this->createElement(str, splits, item);
				}
			} else {
				if (this->getCommand(str)) {
					let converted = (new Text())->processValue(str);
					if (converted == null) {
						let converted = (new Maths())->processValue(str);
					}
					if (converted == null) {
						throw new Exception("Invalid command");
					}
				} else {
					let converted = this->clean(
						str,
						this->isVariable(str)
					);
				}
			}

			if (javascript) {
				let converted = "\"<?= (new KytschBASIC\\Parsers\\Core\\Variables())->outputForJavascript(" . converted . "); ?>\"";
			}

			let cleaned .= converted . (javascript ? " + " : " . ");
		}

		let cleaned = rtrim(cleaned, (javascript ? " + " : " . "));

		let output .= cleaned;
		
		return output . (javascript ? "\n</script>\n" : "; ?>");
	}

	public function dump(output, bool html = false)
	{
		if (substr(output, 0, 3) == "\"{$") {
			let output = this->cleanVarOnly(output, false);
		}

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
			return strings[0];
		}
	
		return null;
	}

	public function isFormVariable(string arg)
	{
		if (substr(arg, 0, 1) == "\"" || is_numeric(arg)) {
			return false;
		}

		var val;

		for val in this->form_variables {
			if (substr(arg, 0, strlen(val)) == val) {
				return true;
			}
		}
		
		return false;
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

	public function outputArg(arg, bool in_quotes = true, bool clean = false)
	{
		let arg = trim(arg, "\"");

		if (clean && this->isVariable(arg)) {
			let arg = str_replace(" ", "", arg);
		}

		return (in_quotes ? "\\\"" : "\"") . arg . (in_quotes ? "\\\"" : "\"");
	}	

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
	
	public function parse(string command, string args)
	{	
		var cleaned;

		switch (this->getCommand(command)) {
			case "2DP":
				return this->processTwoDP(command);
			case "ADEF":
				return this->processDef(args, false, true);
			case "ADIM":
				return this->processDim(args, true);
			case "BENCHMARK":
				return this->processBenchmark();
			case "DEF":
				return this->processDef(args);
			case "DIM":
				return this->processDim(args);
			case "DUMP":
				let cleaned = this->cleanArg("DUMP", command);
				return this->dump(this->clean(cleaned, this->isVariable(cleaned)), true);
			case "LET":
				return this->processDef(args, true);
			case "MERGE":
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
				return this->processSSort(command);
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

	private function processDef(string line, bool let_var = false, bool javascript = false)
	{
		var splits, split, vars;

		preg_match_all("/(?<!\")(?:\$=|%=|#=|&=)/", trim(line), splits);

		if (empty(splits[0])) {
			preg_match_all("/(?<!\")(?:\$\(|%\(|#\(|&\()/", trim(line), splits);

			if (empty(splits[0])) {
				throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
			}
		}

		for split in splits[0] {
			switch (split) {
				case "%=":
					let vars = explode("%=", line, 2);
					return this->createInt(vars[0], vars, "", javascript);
				case "$=":
					let vars = explode("$=", line, 2);
					return this->createString(line, vars, "", javascript);
				case "#=":
					let vars = explode("#=", line, 2);
					return this->createDouble(vars[0], vars);
				default:
					let vars = explode(")=", line, 2);
					return this->setArrayElement(line, vars, split);
			}
		}
	}

	private function processDim(string line, bool javascript = false)
	{
		if (strpos(line, "$=") !== false) {
			return this->createArray(line, explode("$=", line), javascript);
		} elseif (strpos(line, "%=") !== false) {
			return this->createArray(line, explode("%=", line), javascript);
		} elseif (strpos(line, "#=") !== false) {
			return this->createArray(line, explode("#=", line), javascript);
		}
	}

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

	public function processTwoDP(args)
	{
		let args = this->args(this->cleanArg("2DP", args));
		return "<?php " . this->cleanVarOnly(args[0]) . " = number_format(" . args[0] . ", 2, '.', ''); ?>";
	}

	private function setArrayElement(string line, splits, string type)
	{
		var output = "<?php $", vars, cleaned;

		let vars = explode(type, splits[0]);
				
		if (isset(vars[1])) {
			let output .= vars[0] . "[";
			if (is_numeric(vars[1])) {
				let output .= vars[1];
			} else {
				let cleaned = this->clean(
					vars[1],
					this->isVariable(vars[1])
				);

				if (substr(cleaned, 0, 3) == "\"{$") {
					let cleaned = this->cleanVarOnly(cleaned, false);
				}

				let output .= cleaned;
			}

			let output .= "] = ";
		} else {
			let output .= vars[0] . "[] = ";
		}
		
		let output .= this->createElement(line, splits, type);

		return output . "; ?>";
	}
}
