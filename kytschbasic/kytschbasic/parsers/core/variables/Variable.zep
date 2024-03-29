/**
 * Variable parser
 *
 * @package     KytschBASIC\Parsers\Core\Variables\Variable
 * @author 		Mike Welsh
 * @copyright   2023 Mike Welsh
 * @version     0.0.2
 *
 * Copyright 2023 Mike Welsh
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
namespace KytschBASIC\Parsers\Core\Variables;

use KytschBASIC\Parsers\Core\Command;

class Variable extends Command
{
	public function parse(
		string line,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (this->match(line, "LET")) {
			var args = this->parseArgs("LET", line);
			let args = explode("=", args[0]);

			let line = implode("=", array_slice(args, 1, count(args) - 1));

			return "<?php $" . str_replace(["$", "%", "#"], "", args[0]) . "=" . this->parseEquation(line) . "; ?>";
		} elseif (this->match(line, "DEF")) {
			var args = this->parseArgs("DEF", line);
			let args = explode("=", args[0]);

			let line = implode("=", array_slice(args, 1, count(args) - 1));

			return "<?php $" . str_replace(["$", "%", "#"], "", args[0]) . "=" . this->parseEquation(line) . "; ?>";
		} elseif (this->match(line, "DUMP")) {
			var args = this->parseArgs("DUMP", line);
			return "<pre><?=var_dump($" . str_replace(["$", "%", "#", "&"], "", args[0]) . ");?></pre>";
		}

		return null;
	}
}