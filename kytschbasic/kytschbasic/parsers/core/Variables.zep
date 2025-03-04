/**
 * Variables parser
 *
 * @package     KytschBASIC\Parsers\Core\Variables
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2024 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
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
use KytschBASIC\Parsers\Core\Maths;
use KytschBASIC\Parsers\Core\Text\Text;

class Variables
{
	public types = ["$", "%", "#", "&"];

	public function args(string line)
	{
		if (empty(line)) {
			return [];
		}

		var args, arg, key, replace;

		let replace = md5(time());

		let line = preg_replace_callback(
			"/\"[^\"]+\"/",
			function (match) use (replace) {
				return str_replace(";", replace, match[0]);
			},
			line
		);

		let args = explode(";", line);
		for key, arg in args {
			let args[key] = str_replace(replace, ";", arg);
		}
		return args;
	}

	public function clean(string line, bool inline_string = true)
	{
		var args, arg, maths = "";

		let args = this->args(line);
		let line = "";
		
		for arg in args {
			let maths = Maths::parse(arg);
			if (maths) {
				let line .= maths;
			} else {
				if (is_numeric(arg)) {
					let line .= arg . ".";
				} else {
					let line .= (inline_string ? "{" : "") . "$" . trim(str_replace(this->types, "", arg)) . (inline_string ? "}" : "");
				}
			}
		}
		
		return Maths::equation(rtrim(line, "."));
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
		} elseif (command == "2DP") {
			return "<?php " . $this->clean(args, false) . " = number_format(" . $this->clean(args, false) . ", 2, '.', ''); ?>";
		} elseif (command == "DUMP") {
			return "<?php var_dump(" . $this->clean(args, false) . "); ?>";
		} elseif (command == "BENCHMARK") {
			return this->processBenchmark();
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
				return "<?php $" . splits[0] . " = intval(" . this->clean(splits[1], false) . "); ?>";
			} else {
				throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
			}
		} elseif (strpos(line, "#=") !== false) {
			let splits = explode("#=", line);
			if (count(splits) > 1) {
				return "<?php $" . splits[0] . " = (double)" . this->clean(splits[1], false) . "; ?>";
			} else {
				throw new Exception("Invalid " . (let_var ? "LET" : "DEF"));
			}
		} else {
			return "<?php " . this->clean(line, false) . "; ?>";
		}		
	}
}
