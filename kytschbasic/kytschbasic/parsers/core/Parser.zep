/**
 * Parser
 *
 * @package     KytschBASIC\Parsers\Core\Parser
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.4
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
use KytschBASIC\Parsers\Core\CoreFunc;

class Parser
{
	private line_no = 0;
	private newline = "\n";
	private cprint = false;
	private js = false;
	private create_function = false;
	private has_case = false;
	private show_html = false;

	private websocket_server = null;

	private controller;
		
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
		"KytschBASIC\\Parsers\\Core\\Media\\Files",
		"KytschBASIC\\Parsers\\Core\\Navigation",
		"KytschBASIC\\Parsers\\Core\\Layout\\Table",
		"KytschBASIC\\Parsers\\Core\\Conditional\\Loops",
		"KytschBASIC\\Parsers\\Core\\Load",
		"KytschBASIC\\Parsers\\Core\\Database",
		"KytschBASIC\\Parsers\\Core\\Session",
		"KytschBASIC\\Parsers\\Core\\Communication\\Mail",
		"KytschBASIC\\Parsers\\Core\\Communication\\Websocket\\Websocket",
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
		"KytschBASIC\\Libs\\Arcade\\Parsers\\Sprite"
	];

	/*
	 * Build the template by parsing the lines.
	 */
	public function parse(string template, bool show_html_mode = false)
	{
		var command = "", args = [], line = "", lines, output = "", err;

		let this->cprint = false;
		let this->js = false;
		let this->create_function = false;
		let this->controller = new Command();

		if (show_html_mode) {
			let this->show_html = true;
		}
		
		if (!file_exists(template)) {
			throw new Exception("Template, " . template . ", not found");
		}
		
		try {
			// Read the template lines.
			let lines = file(template);
			if (empty(lines)) {
				return;
			}

			for line in lines {
				if (!this->cprint) {
					let line = trim(line);
				}
				
				let this->line_no += 1;
				
				if (line == "") {
					continue;
				}

				let command = this->controller->getCommand(line);
				if (command == null) {
					let command = "";
				} elseif (!this->cprint && command != "REM" && command != "SPRINT") {
					let args = this->controller->args(trim(ltrim(line, command)));
				}

				let output .= this->processCommand(line, command, args);
			}
		} catch \Exception, err {
			throw new Exception(err->getMessage(), err->getCode(), true, this->line_no);
		}

		return output;
    }

	private function processCommand(string line, string command, array args)
	{
		var output = "", parser, cleaned;

		switch (command) {
			case "SPRINT":
				return trim(ltrim(line, "SPRINT"));
			case "CPRINT":
				let this->cprint = true;
				return "<pre><code>";
			case "END CPRINT":
				let this->cprint = false;
				return "</code></pre>";
			case "JAVASCRIPT":
				if (!this->cprint) {
					let this->js = true;
					return "<script type='text/javascript'>";
				} elseif (this->cprint || (this->js && !this->create_function)) {
					return line . this->newline;
				}
				break;
			case "END JAVASCRIPT":
				if (!this->cprint) {
					let this->js = false;
					return "</script>";
				}  elseif (this->cprint || (this->js && !this->create_function)) {
					return line . this->newline;
				}
				break;
			case "AFUNCTION":
				if (!this->cprint) {
					let this->js = true;
					return (new AFunction())->parse(line, command, args);
				}  elseif (this->cprint || (this->js && !this->create_function)) {
					return line . this->newline;
				}
				break;
			case "END AFUNCTION":
				if (!this->cprint) {
					let this->js = false;
					return (new AFunction())->parse(line, command, args);
				}  elseif (this->cprint || (this->js && !this->create_function)) {
					return line . this->newline;
				}
				break;
			case "FUNCTION":
				if (!this->cprint) {
					let this->create_function = true;
					return (new CoreFunc())->parse(line, command, args);
				}  elseif (this->cprint || (this->js && !this->create_function)) {
					return line . this->newline;
				}
				break;
			case "END FUNCTION":
				if (!this->cprint) {
					let this->create_function = false;
					return "<?php }\n?>";
				}  elseif (this->cprint) {
					return line . this->newline;
				}
				break;
			case "ANIMATION":
				if (!this->cprint) {
					let this->js = true;
					let this->create_function = true;
					return (new AFunction())->parse(line, command, args);
				}  elseif (this->cprint || (this->js && !this->create_function)) {
					return line . this->newline;
				}
				break;
			case "END ANIMATION":
				if (!this->cprint) {
					let this->js = false;
					let this->create_function = false;
					return (new AFunction())->parse(line, command, args);
				}  elseif (this->cprint || (this->js && !this->create_function)) {
					return line . this->newline;
				}
				break;
			default:
				if (this->cprint || (this->js && !this->create_function)) {
					return line . this->newline;
				}
				break;
		}

		switch (command) {
			case "REM":
				return "";
			case "ALET":
				return (new AFunction())->processDef(line, args, true, true, true);
			case "SLEEP":
				if (!this->js) {
					if (!isset(args[0])) {
						let args[0] = 1000;
					} elseif (empty(args[0])) {
						let args[0] = 1000;
					} elseif (args[0] <= 0) {
						let args[0] = 1000;
					}
					let args[0] = args[0] * 1000;
					return "<?php usleep(" . args[0] . "); ?>";
				} else {
					return "\tawait sleep(" . args[0] . ");\n";
				}
			case "SHOWHTML":
				let this->show_html = true;
				return "<?php ob_start(); ?>";
			case "END SHOWHTML":
				let this->show_html = false;
				return "<?php $KBHTMLENCODE = ob_get_clean();echo '<pre><code>' . htmlentities($KBHTMLENCODE) . '</code></pre>'; ?>";
			case "CONTINUE":
				return "<?php continue; ?>";
			case "CODE":
				return "<pre><code>";
			case "END CODE":
				return "</code></pre>";
			case "SHOW":
				return (new AFunction())->parse(line, command, args, this->js);
			case "HIDE":
				return (new AFunction())->parse(line, command, args, this->js);
			case "IF":
				return this->processIf(line, "if", args);
			case "IFNTE":
				return this->processIf(line, "if", args, true);
			case "IFE":
				return this->processIf(line, "if", args, false, true);
			case "ELSEIF":
				return this->processIf(line, "elseif", args);
			case "ELSE":
				return "<?php else : ?>";
			case "END IF":
				return "<?php endif; ?>";
			case "BREAK":
				return "<?php break; ?>";
			case "CASE":
				if (this->has_case) {
					let output .= "<?php break; ?>";
					let this->has_case = false;
				}

				if (count(args) < 1) {
					throw new Exception("Invalid CASE");
				}
		
				let this->has_case = true;
	
				return output . "<?php case " . args[0] . ": ?>";
			case "DEFAULT":
				if (this->has_case) {
					let output .= "<?php break; ?>";
					let this->has_case = false;
				}
				let this->has_case = true;
				return output . "<?php default: ?>" ;
			case "SELECT":
				if (count(args) < 1) {
					throw new Exception("Invalid SELECT");
				}
				return "<?php switch(" . args[0] . ") { ?>";
			case "END SELECT":
				if (this->has_case) {
					let output .= "<?php break; ?>";
					let this->has_case = false;
				}
				return output . "<?php } ?>";
			case "VERSION":
				return "<span class=\"kb-version\">" . constant("VERSION") . "</span>";
		}
		
		for parser in this->available {
			let cleaned = (new {parser}())->parse(line, command, args);
			if (cleaned !== null) {
				let output .= cleaned . this->newline;
				if (substr(cleaned, strlen(cleaned) - 2, 2) == "?>" && this->show_html) {
					let output .= this->newline;
				}
				break;
			}
		}
		return output;
	}

	private function processIf(string line, string command = "if", array args = [], bool not_empty = false, bool is_empty = false)
	{
		var output = "", splits;

		if (!count(args)) {
			throw new Exception("Invalid IF statement");
		}
		
		let output = "<?php " . command . " (";

		let splits = preg_split("/THEN(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", args[0]);
		if (!count(splits)) {
			throw new Exception("Invalid IF statement");
		}

		let splits[0] = this->controller->setDoubleEquals(trim(splits[0]));
						
		if (not_empty) {
			let output .= "!empty(" . splits[0] . ")";
		} elseif (is_empty) {
			let output .= "empty(" . splits[0] . ")";
		} else {
			let output .= splits[0];
		}

		let output .= ") : ?>";
		
		return output;
	}
}
