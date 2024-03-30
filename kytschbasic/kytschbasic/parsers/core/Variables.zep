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

use KytschBASIC\Parsers\Core\Maths;

class Variables
{
	public function args(string line)
	{
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

	public function clean(string line)
	{
		var args, arg;

		let args = this->args(line);
		let line = "";
		
		for arg in args {
			let line .= "$" . str_replace(["$", "%", "#"], "", arg) . ".";
		}

		return (new Maths())->parse(rtrim(line, "."));
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
			return this->processLet(args);
		}
	}

	private function processLet(string line)
	{
		return "<?php " . this->clean(line) . "; ?>";
	}
}
