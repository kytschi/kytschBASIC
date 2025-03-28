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
use KytschBASIC\Parsers\Core\Variables;
use KytschBASIC\Libs\Arcade\Parsers\AFunction;

class Parser
{
	private line_no = 0;
	private newline = "\n";
	private cprint = false;
	private has_case = false;
		
	/*
	 * Available parsers.
	 */
	private available = [
		"KytschBASIC\\Parsers\\Core\\Text\\Text",
		"KytschBASIC\\Parsers\\Core\\Input\\Button",
		"KytschBASIC\\Parsers\\Core\\Input\\Form",
		"KytschBASIC\\Parsers\\Core\\Layout\\Layout",
		"KytschBASIC\\Parsers\\Core\\Text\\Heading",
		"KytschBASIC\\Parsers\\Core\\Layout\\Head",
		"KytschBASIC\\Parsers\\Core\\Variables",
		"KytschBASIC\\Parsers\\Core\\Media\\Image",
		"KytschBASIC\\Parsers\\Core\\Navigation",
		"KytschBASIC\\Parsers\\Core\\Layout\\Table",
		"KytschBASIC\\Parsers\\Core\\Conditional\\Select",
		"KytschBASIC\\Parsers\\Core\\Conditional\\Loops",
		"KytschBASIC\\Parsers\\Core\\Load",
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
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Screen\\Sprite",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Screen\\Window",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Shapes\\Shape"
	];

	/*
	 * Build the template by parsing the commands.
	 */
	public function parse(string template)
	{
		var err, command = "", args = "", line = "", parser, commands, output = "";

		let this->cprint = false;

		try {
			if (!file_exists(template)) {
				throw new Exception("Template, " . template . ", not found");
			}
			
			// Read the template lines.
			let commands = file(template);
			if (empty(commands)) {
				return;
			}		

			for line in commands {
				let this->line_no += 1;
				
				if (line == "") {
					continue;
				}

				let parser = explode(" ", trim(line));
				let command = parser[0];
				array_shift(parser);

				if (isset(parser[0])) {
					if (command == "END") {
						let command .= " " . parser[0];
						array_shift(parser);
					} elseif (parser[0] == "BREAK") {
						let command .= " BREAK";
						array_shift(parser);
					}
				}
				
				let args = implode(" ", parser);
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

	private function processCommand(line, string command, args)
	{
		var output = "", parser;

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
			return (new AFunction())->parse(command, args);
		} elseif (command == "END AFUNCTION") {
			let this->cprint = false;
			return (new AFunction())->parse(command, args);
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
		} elseif (command == "ELSEIF") {
			return this->processIf(line, "elseif", args);
		} elseif (command == "ELSE") {
			return "<?php else: ?>";
		} elseif (trim(command) == "END IF") {
			return "<?php endif; ?>";
		} elseif (command == "CASE") {
			if (this->has_case) {
				let output .= "<?php break; ?>" . this->newline;
				let this->has_case = false;
			}

			let parser = new Command();

			let output .= "<?php case " .
			parser->clean(
					args,
					false,
					in_array(substr(args, strlen(args) - 1, 1), parser->types) ? true : false
				)
				. ": ?>" . this->newline;

			let this->has_case = true;

			return output;
		} elseif (command == "DEFAULT") {
			if (this->has_case) {
				let output .= "<?php break; ?>" . this->newline;
				let this->has_case = false;
			}
			let output .= "<?php default: ?>" . this->newline;
			let this->has_case = true;

			return output;
		} elseif (command == "END SELECT") {
			if (this->has_case) {
				let output .= "<?php break; ?>" . this->newline;
				let this->has_case = false;
			}
			return "<?php } ?>";
		} elseif (command == "VERSION") {
			return "<span class=\"kb-version\">" . constant("VERSION") . "</span>";
		}

		for parser in this->available {
			let line = (new {parser}())->parse(command, args);
			if (line !== null) {
				let output .= line . this->newline;
				break;
			}
		}
		return output;
	}

	private function processIf(line, string command = "if", args, bool not_empty = false)
	{
		var output = "", parser, controller;

		let controller = new Command();

		let args = explode(" THEN", args);
		
		let output = "<?php " . command . " (";

		if (not_empty) {
			let output .= "!empty(" .
				controller->clean(args[0], controller->isVariable(args[0])) . ")";
		} else {
			let output .= controller->clean(args[0], controller->isVariable(args[0]));
		}

		let output .= "): ?>";

		if (count(args) > 1) {
			if (!empty(trim(args[1]))) {
				let parser = explode(" ", trim(args[1]));
				if (count(parser) > 1) {
					let output .= this->processCommand(line, parser[0], parser[1]);
				}
			}
		}
		
		return output;
	}
}
