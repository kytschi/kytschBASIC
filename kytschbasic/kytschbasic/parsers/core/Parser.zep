/**
 * Parser
 *
 * @package     KytschBASIC\Parsers\Core\Parser
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.3
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
use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Maths;
use KytschBASIC\Parsers\Core\Variables;
use KytschBASIC\Libs\Arcade\Parsers\AFunction;

class Parser
{
	private line_no = 0;
	private newline = "\n";
	private cprint = false;
	private has_case = false;

	private controller;
		
	/*
	 * Available parsers.
	 */
	private available = [
		"KytschBASIC\\Parsers\\Core\\Text\\Text",
		/*"KytschBASIC\\Parsers\\Core\\Input\\Button",
		"KytschBASIC\\Parsers\\Core\\Input\\Form",
		"KytschBASIC\\Parsers\\Core\\Layout\\Layout",
		"KytschBASIC\\Parsers\\Core\\Text\\Heading",
		"KytschBASIC\\Parsers\\Core\\Layout\\Head",*/
		"KytschBASIC\\Parsers\\Core\\Variables",
		/*
		"KytschBASIC\\Parsers\\Core\\Media\\Image",
		"KytschBASIC\\Parsers\\Core\\Navigation",
		"KytschBASIC\\Parsers\\Core\\Layout\\Table",
		"KytschBASIC\\Parsers\\Core\\Conditional\\Select",
		*/
		"KytschBASIC\\Parsers\\Core\\Conditional\\Loops"
		/*"KytschBASIC\\Parsers\\Core\\Load",
		"KytschBASIC\\Parsers\\Core\\Database",
		"KytschBASIC\\Parsers\\Core\\Communication\\Mail",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Bitmap",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Colors\\Color",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Shapes\\Arc",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Shapes\\Box",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Shapes\\Circle",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Shapes\\Ellipse",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Shapes\\Line",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Screen\\Screen",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Screen\\Window",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Shapes\\Shape",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Sprite"*/
	];

	/*
	 * Build the template by parsing the lines.
	 */
	public function parse(string template)
	{
		var err, command = "", args = "", line = "", lines, output = "";

		let this->cprint = false;

		try {
			if (!file_exists(template)) {
				throw new Exception("Template, " . template . ", not found");
			}
			
			// Read the template lines.
			let lines = file(template);
			if (empty(lines)) {
				return;
			}

			let this->controller = new Command();

			for line in lines {
				let line = trim(line);
				
				let this->line_no += 1;
				
				if (line == "") {
					continue;
				}

				let command = this->controller->getCommand(line);
				if (command == null) {
					let command = "";
				} else {
					let args = this->controller->args(trim(str_replace(command, "", line)));
				}

				let output .= this->processCommand(line, command, args);
			}

			return output;
		} catch Exception, err {
		    err->fatal(template, this->line_no);
		} catch \RuntimeException|\Exception, err {
			var newErr;
			let newErr = new Exception(err->getMessage(), err->getCode());

			echo newErr->fatal(template, this->line_no);
		}
    }

	private function processCommand(string line, string command, array args)
	{
		var output = "", parser, cleaned;

		if (command == "CPRINT") {
			let this->cprint = true;
			return "<pre><code>" . this->newline;
		} elseif (command == "END CPRINT") {
			let this->cprint = false;
			return "</code></pre>" . this->newline;
		} elseif (command == "JAVASCRIPT") {
			let this->cprint = true;
			return "<script type='text/javascript'>" . this->newline;
		} elseif (command == "END JAVASCRIPT") {
			let this->cprint = false;
			return "</script>" . this->newline;
		} elseif (command == "AFUNCTION") {
			let this->cprint = true;
		} elseif (command == "END AFUNCTION") {
			let this->cprint = false;
		}

		if (this->cprint) {
			return line;
		}
		
		if (command == "SPRINT") {
			return str_replace("SPRINT ", "", line) . this->newline;
		} elseif (command == "REM") {
			return;
		} elseif (command == "IF") {
			return this->processIf(line, "if", args);
		} elseif (command == "IFNTE") {
			return this->processIf(line, "if", args, true);
		} elseif (command == "IFE") {
			return this->processIf(line, "if", args, false, true);
		} elseif (command == "ELSEIF") {
			return this->processIf(line, "elseif", args);
		} elseif (command == "ELSE") {
			return "<?php else: ?>\n";
		} elseif (trim(command) == "END IF") {
			return "<?php endif; ?>\n";
		} elseif (trim(command) == "BREAK") {
			return "<?php break; ?>\n";
		} elseif (command == "CASE") {
			if (this->has_case) {
				let output .= "<?php break; ?>\n" . this->newline;
				let this->has_case = false;
			}

			let parser = new Command();

			/*let output .= "<?php case " .
				parser->clean(
					args,
					parser->isVariable(args)
				)
				. ": ?>\n" . this->newline;*/

			let this->has_case = true;

			return output;
		} elseif (command == "DEFAULT") {
			if (this->has_case) {
				let output .= "<?php break; ?>\n" . this->newline;
				let this->has_case = false;
			}
			let output .= "<?php default: ?>\n" . this->newline;
			let this->has_case = true;

			return output;
		} elseif (command == "END SELECT") {
			if (this->has_case) {
				let output .= "<?php break; ?>\n" . this->newline;
				let this->has_case = false;
			}
			return "<?php } ?>\n";
		} elseif (command == "VERSION") {
			return "<span class=\"kb-version\">" . constant("VERSION") . "</span>";
		}

		for parser in this->available {
			let cleaned = (new {parser}())->parse(line, command, args);
			if (cleaned !== null) {
				let output .= cleaned . this->newline;
				break;
			}
		}
		return output;
	}

	private function processIf(string line, string command = "if", array args = [], bool not_empty = false, bool is_empty = false)
	{
		var output = "", splits;

		if (empty(args[0])) {
			throw new Exception("Invalid IF statement");
		}

		let output = "<?php " . command . " (";

		let splits = preg_split("/THEN(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", args[0]);
		if (empty(splits[0])) {
			throw new Exception("Invalid IF statement");
		}

		if (not_empty) {
			let output .= "!empty(" . trim(splits[0]) . ")";
		} elseif (is_empty) {
			let output .= "empty(" . trim(splits[0]) . ")";
		} else {
			let output .= trim(splits[0]);
		}

		let output .= "): ?>\n";
		
		return output;
	}
}
