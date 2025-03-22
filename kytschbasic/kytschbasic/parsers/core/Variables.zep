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

	public function args(string line)
	{
		if (empty(line)) {
			return [];
		}

		if (substr(line, 0, 1) == "(") {
			return [line];
		}

		return preg_split("/,(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", line);
	}

	public function clean(string line, bool inline_string = true, bool variable = true)
	{
		var args, arg, maths = "";

		let args = this->args(trim(line));
		
		let line = "";
		
		for arg in args {
			let maths = Maths::parse(arg);
			if (maths !== null) {
				let line .= maths;
			} else {
				let maths = Display::parse(arg);

				if (maths !== null) {
					let line .= maths;
				} else {
					let line .= (inline_string ? "{" : "") .
						(variable ? "$" . str_replace(this->types, "", arg) : arg) .
						(inline_string ? "}" : "");
				}
			}
		}
		
		return (maths !== null) ? Maths::equation(line) : line;
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

	public function getCommand(string line)
	{
		var strings;
				
		if (preg_match("/[A-Z]+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", line, strings)) {
			return strings[0];
		}
	
		return null;
	}

	public function parse(string command, string args)
	{
		if (command == "LET") {
			return this->processDef(args, true);
		} elseif (command == "DEF") {
			return this->processDef(args);
		} elseif (command == "ADEF") {
			return this->processDef(args, false, true);
		} elseif (command == "DIM") {
			return this->processDim(args);
		} elseif (command == "ADIM") {
			return this->processDim(args, true);
		} elseif (command == "2DP") {
			return "<?php " . this->clean(args, false) . " = number_format(" . this->clean(args, false) . ", 2, '.', ''); ?>";
		} elseif (command == "SHUFFLE") {
			return "<?php shuffle(" . this->clean(args, false) . "); ?>";
		} elseif (command == "SORT") {
			return "<?php sort(" . this->clean(args, false) . "); ?>";
		} elseif (command == "SSORT") {
			return "<?php sort(" . this->clean(args, false) . ", SORT_STRING); ?>";
		} elseif (command == "NATSORT") {
			return "<?php natsort(" . this->clean(args, false) . "); ?>";
		} elseif (command == "POP") {
			return this->arrayMod(args);
		} elseif (command == "SHIFT") {
			return this->arrayMod(args, false);
		} elseif (command == "DUMP") {
			return "<?php var_dump(" . this->clean(args, false) . "); ?>";
		} elseif (command == "BENCHMARK") {
			return this->processBenchmark();
		}
	}

	private function arrayMod(args, bool pop = true)
	{
		var value;
		let args = this->args(args);

		let value = this->clean(args[0], false);

		if (pop) {
			if (count(args) > 1) {
				return "<?php array_splice(" .
					value . ", " .
					"count(" . value . ") - 1 - 
					intval(" .
						this->clean(args[1], false, in_array(substr(args[1], strlen(args[1]) - 1, 1), this->types) ? true : false) .
					"),
					1); ?>";
			} else {
				return "<?php array_pop(" . value . "); ?>";
			}
		} else {
			if (count(args) > 1) {
				return "<?php array_splice(" .
					this->clean(args[0], false) . ",
					intval(" .
						this->clean(
							args[1],
							false,
							in_array(substr(args[1], strlen(args[1]) - 1, 1), this->types) ? true : false
						) . "),
					1); ?>";
			} else {
				return "<?php array_shift(" . value . "); ?>";
			}
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

	private function setArrayElement(string line, splits, string type)
	{
		var output = "<?php $", vars;

		let vars = explode(type, splits[0]);

		if (isset(vars[1])) {
			let output .= vars[0] . "[" . 
				this->clean(
					vars[1],
					false,
					in_array(substr(vars[1], strlen(vars[1]) - 1, 1), this->types) ? true : false
				) .
				"] = ";
		} else {
			let output .= vars[0] . "[] = ";
		}
		
		let output .= this->createElement(line, splits, type);

		return output . "; ?>";
	}

	private function createElement(string line, splits, string type)
	{
		var vars, output = "";

		if (substr(line, strlen(line) - 1, 1) == ")") {
			let vars =  preg_split("/(?<!\")(?:\$\(|%\(|#\(|&\()/", rtrim(splits[1], ")"));

			let output .= "$" . vars[0] . "[";

			if (is_numeric(vars[1])) {
				let output .= vars[1];
			} else {
				let output .= this->clean(
					vars[1],
					false,
					in_array(substr(vars[1], strlen(vars[1]) - 1, 1), this->types) ? true : false
				);
			}

			let output .= "]";
		} else {
			var str, cleaned = "";

			let vars = preg_split("/\+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", splits[1]);

			for str in vars {
				let str = trim(str);

				let cleaned .= this->clean(
					str,
					false,
					in_array(substr(str, strlen(str) - 1, 1), this->types) ? true : false
				) . " . ";
			}

			let cleaned = rtrim(cleaned, " . ");

			if (type == "%(") {
				let cleaned = "intval(" . cleaned . ")";
			} elseif (type == "#(") {
				let cleaned = "(double)" . cleaned . "";
			}

			let output .= cleaned;
		}

		return output;
	}

	private function createInt(string line, splits, string var_type = "", bool javascript = false)
	{
		var output = "<?php $", converted = "";

		if (javascript) {
			let output = "<script type='text/javascript'>var ";
		}

		array_shift(splits);

		let output .= line . var_type . " = ";

		if (is_numeric(splits[0])) {
			let converted = splits[0];
		} else {
			let converted = (new Misc())->processFunction(splits);
		}

		if (javascript) {
			let converted = "\"<?= (new KytschBASIC\\Parsers\\Core\\Variables())->outputForJavascript(" . converted . "); ?>\"";
		}

		return output . (javascript ? "parseInt(" . converted . ");</script>" : "intval(" . converted . "); ?>");
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
			let output = "<script type='text/javascript'>var ";
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
				} else {
					let converted = this->clean(
						str,
						false,
						in_array(substr(str, strlen(str) - 1, 1), this->types) ? true : false
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
		
		return output . (javascript ? "</script>" : "; ?>");
	}

	private function createArray(string line, splits, bool javascript = false)
	{
		var output = "<?php $", converted = "";

		if (javascript) {
			let output = "<script type='text/javascript'>var ";
		}

		if (count(splits) > 1) {
			let output .= splits[0] . " = ";
			
			if (in_array(substr(line, strlen(line) - 1, 1), this->types)) {
				let converted = this->clean(
					splits[1],
					false,
					in_array(substr(line, strlen(line) - 1, 1), this->types) ? true : false
				);
			} elseif (substr(line, strlen(line) - 2, 1) == "\")") {
				let converted = str_replace(")", "]", str_replace("(", "[", splits[1])) . ")";
			} else {
				let converted = "array(" . str_replace(["(", ")"], "", splits[1]) . ")";
			}

			if (javascript) {
				let output .= "<?= (new KytschBASIC\\Parsers\\Core\\Variables())->outputForJavascript(" . converted . "); ?>";
			} else {
				let output .= converted;
			}

			return output . (javascript ? "</script>" : "; ?>");
		} else {
			throw new Exception("Invalid DIM");
		}		
	}

	public function outputForJavascript(value)
	{
		if (is_array(value) || is_object(value)) {
			echo json_encode(value);
		} else {
			echo value;
		}		
	}
}
