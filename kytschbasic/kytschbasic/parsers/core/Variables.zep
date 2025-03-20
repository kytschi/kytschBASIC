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

	public function parse(string command, string args)
	{
		if (command == "LET") {
			return this->processDef(args, true);
		} elseif (command == "DEF") {
			return this->processDef(args);
		} elseif (command == "DIM") {
			return this->processDim(args);
		} elseif (command == "2DP") {
			return "<?php " . this->clean(args, false) . " = number_format(" . this->clean(args, false) . ", 2, '.', ''); ?>";
		} elseif (command == "SHUFFLE") {
			return "<?php shuffle(" . this->clean(args, false) . "); ?>";
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

	private function processDef(string line, bool let_var = false)
	{
		var splits;

		if (strpos(line, "%=") !== false) {
			let splits = explode("%=", line);
			if (count(splits) > 1) {
				return this->createInt(splits[0], splits);
			} else {
				throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
			}
		} elseif (strpos(line, "%(") !== false) {
			let splits = explode(")=", line, 2);
			if (count(splits) > 1) {
				return "<?php $" .
					ltrim(splits[0], "%(") .
					" = intval(" .
					this->clean(
						splits[1],
						false, 
						in_array(substr(line, strlen(line) - 1, 1), this->types) ? true : false
					) . 
				"); ?>";
			} else {
				throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
			}
		} elseif (strpos(line, "#=") !== false) {
			let splits = explode("#=", line);
			if (count(splits) > 1) {
				return "<?php $" .
					splits[0] .
					" = (double)" .
					this->clean(
						splits[1],
						false,
						in_array(substr(line, strlen(line) - 1, 1), this->types) ? true : false
					) . "; ?>";
			} else {
				throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
			}
		} elseif (strpos(line, "$=") !== false) {
			let splits = explode("$=", line);
			if (count(splits) > 1) {
				return this->createString(line, splits);
			} else {
				throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
			}
		} elseif (strpos(line, "$(") !== false) {
			let splits = explode(")=", line, 2);
			if (count(splits) > 1) {
				return this->setArrayElement(line, splits, "$(");
			} else {
				throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
			}
		} else {
			throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
		}		
	}

	private function processDim(string line)
	{
		if (strpos(line, "$=") !== false) {
			return this->createArray(line, explode("$=", line));
		} elseif (strpos(line, "%=") !== false) {
			return this->createArray(line, explode("%=", line));
		} elseif (strpos(line, "#=") !== false) {
			return this->createArray(line, explode("#=", line));
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
			var str;

			let vars = preg_split("/\+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", splits[1]);

			for str in vars {
				let str = trim(str);

				let output .= this->clean(
					str,
					false,
					in_array(substr(str, strlen(str) - 1, 1), this->types) ? true : false
				) . " . ";
			}

			let output = rtrim(output, " . ");
		}

		return output . "; ?>";
	}

	private function createInt(string line, splits, var_type = "")
	{
		var output = "<?php $";

		array_shift(splits);

		let output .= line . var_type . " = intval(";

		if (is_numeric(splits[0])) {
			let output .= splits[0];
		} else {
			let output .= (new Misc())->processFunction(splits);
		}

		return output . "); ?>";
	}

	private function createString(string line, splits, var_type = "")
	{
		var strings, str = "", value = "";

		let strings = preg_split("/\+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", splits[1]);

		if (count(strings) > 1) {
			while (count(strings)) {
				let value = trim(strings[0]);
								
				let str .= this->clean(
					value,
					false,
					in_array(substr(value, strlen(value) - 1, 1), this->types) ? true : false
				) . " . ";

				array_shift(strings);
			}
			let value = trim(str, " . ");
		} else {
			if (substr(splits[1], strlen(splits[1]) - 2, 1) != ")") {
				if (substr(splits[1], 0, 1) == "\"") {
					let value = this->setElement(splits[1]);
				} else {
					let strings = this->args(trim(splits[1], " . "));
					let value = (new Text())->processValue(strings);
				}
			} else {
				let strings = this->args(trim(splits[1], " . "));
				let value = (new Text())->processValue(strings);
			}
		}	
		
		return "<?php $" .
			splits[0] .
			var_type . " = " .
			value . "; ?>";
	}

	private function createArray(string line, splits)
	{
		var output = "<?php $";

		if (count(splits) > 1) {
			let output .= splits[0] . " = ";
			
			if (in_array(substr(line, strlen(line) - 1, 1), this->types)) {
				let output .= this->clean(
					splits[1],
					false,
					in_array(substr(line, strlen(line) - 1, 1), this->types) ? true : false
				);
			} elseif (substr(line, strlen(line) - 2, 1) == "\")") {
				let output .= str_replace(")", "]", str_replace("(", "[", splits[1])) . ")";
			} else {
				let output .= "array(" . str_replace(["(", ")"], "", splits[1]) . ")";
			}

			return output . "; ?>";
		} else {
			throw new Exception("Invalid DIM");
		}		
	}

	private function setElement(string value)
	{
		var matches, clean, str;

		for str in this->types {
			if (strpos(value, str) !== false) {
				let value = preg_replace("/\\" . str . "/", "", value, 1);
				break;
			}
		}

		let value = "$" . value;
		
		preg_match_all("/(.*?)(\(.*?\))/", value, matches);

		if (!empty(matches[1]) && !empty(matches[2])) {
			for str in matches[2] {
				let clean = str_replace(")", "", str_replace("(", "", str));
				let value = str_replace(
					str,
					"[" .
					(
						is_numeric(clean) ?
						clean :
						this->clean(
							clean,
							false,
							in_array(substr(clean, strlen(clean) - 1, 1), this->types) ? true : false
						)
					) .
					"]",
					value
				);
			}
		}

		return value;
	}
}
