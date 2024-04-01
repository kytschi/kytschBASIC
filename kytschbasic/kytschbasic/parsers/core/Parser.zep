/**
 * Parser
 *
 * @package     KytschBASIC\Parsers\Core\Parser
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2024 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.3
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
namespace KytschBASIC\Parsers\Core;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Parser
{
	private line_no = 0;
	private newline = "\n";
	private has_case = false;
		
	/*
	 * Available parsers.
	 */
	private available = [
		"KytschBASIC\\Parsers\\Core\\Text\\Text",
		"KytschBASIC\\Parsers\\Core\\Layout\\Layout",
		"KytschBASIC\\Parsers\\Core\\Text\\Heading",
		"KytschBASIC\\Parsers\\Core\\Layout\\Head",
		"KytschBASIC\\Parsers\\Core\\Variables",
		"KytschBASIC\\Parsers\\Core\\Navigation",
		"KytschBASIC\\Parsers\\Core\\Layout\\Table",
		"KytschBASIC\\Parsers\\Core\\Conditional\\Select",
		"KytschBASIC\\Parsers\\Core\\Conditional\\Loops",
		"KytschBASIC\\Parsers\\Core\\Load",
		"KytschBASIC\\Parsers\\Core\\Database",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Bitmap",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Colors\\Color",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Shapes\\Arc",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Shapes\\Box",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Shapes\\Circle",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Shapes\\Line",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Screen\\Screen",
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Screen\\Window"
	];

	/*
	 * Build the template by parsing the commands.
	 */
	public function parse(string template)
	{
		var err, command = "", args = "", line = "", parser, commands, output = "", cprint = false;

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
					if (parser[0] == "CLOSE") {
						let command .= " CLOSE";
						array_shift(parser);
					} elseif (parser[0] == "BREAK") {
						let command .= " BREAK";
						array_shift(parser);
					}
				}
				let args = implode(" ", parser);

				if (command == "CPRINT") {
					let cprint = true;
					let output .= "<pre><code>" . this->newline;
					continue;
				} elseif (command == "CPRINT CLOSE") {
					let cprint = false;
					let output .= "</code></pre>" . this->newline;
					continue;
				} elseif (cprint || command == "SPRINT") {
					let output .= str_replace("SPRINT ", "", line) . this->newline;
					continue;
				} elseif (command == "REM") {
					continue;
				} elseif (command == "CASE") {
					if (this->has_case) {
						let output .= "<?php break; ?>" . this->newline;
						let this->has_case = false;
					}
					let output .= "<?php case " . (new Command())->clean(args) . ": ?>" . this->newline;
					let this->has_case = true;
				} elseif (command == "DEFAULT") {
					if (this->has_case) {
						let output .= "<?php break; ?>" . this->newline;
						let this->has_case = false;
					}
					let output .= "<?php default: ?>" . this->newline;
					let this->has_case = true;
				}

				for parser in this->available {
					let line = (new {parser}())->parse(command, args);
					if (!empty(line)) {
						let output .= line . this->newline;
						break;
					}
				}
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
}
