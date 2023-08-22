/**
 * Parser
 *
 * @package     KytschBASIC\Parsers\Core\Parser
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
namespace KytschBASIC\Parsers\Core;

use KytschBASIC\Arcade;
use KytschBASIC\Events\EventManager;
use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Database;
use KytschBASIC\Parsers\Core\Load;
use KytschBASIC\Parsers\Core\Maths;
use KytschBASIC\Parsers\Core\Text\Text;

class Parser extends Command
{
	private config;
	private globals = [];
	private parsers = [];
	private arcade;

	/**
	 * Used to handle the CPRINT command for outputing to screen rather than parsing.
	 */
	private cprinting = false;

	private line = 0;
	private tab_count = 0;
	private template;
	private template_dir;

	private database;
	private event_manager;
	private event_line_break = false;

	private loops = [];
	private loops_data = [];

	private start_time;

	private output = "";

	private mail = false;
	private mail_options = [];

	private select_started = 0;

	/**
	 * Available parsers.
	 */
	private available = [
		"KytschBASIC\\Parsers\\Core\\Variables\\Variable",
		"KytschBASIC\\Parsers\\Core\\Variables\\Arrays",
		"KytschBASIC\\Parsers\\Core\\Loops\\WhileLoop",
		"KytschBASIC\\Parsers\\Core\\Navigation",
		"KytschBASIC\\Parsers\\Core\\Layout\\Table",
		"KytschBASIC\\Parsers\\Core\\Text\\Heading",
		"KytschBASIC\\Parsers\\Core\\Text\\Text",
		"KytschBASIC\\Parsers\\Core\\Layout\\Form",
		"KytschBASIC\\Parsers\\Core\\Loops\\ForLoop",
		"KytschBASIC\\Parsers\\Core\\Layout\\Layout",
		"KytschBASIC\\Parsers\\Core\\Media",
		"KytschBASIC\\Parsers\\Core\\Layout\\Head"
	];

	/**
	 * Build the template by parsing the commands.
	 */
	public function parse(
		string template,
		var config,
		array globals,
		var start_time
	) {
		let this->config = config;
		let this->globals = globals;		
		let this->template = template;
		let this->start_time = start_time;
		let this->mail_options["from"] = "dev@kytschi.com";
		let this->mail_options["subject"] = "kytschBASIC email";

		var err;

		try {
			if (!file_exists(template)) {
				throw new Exception("Template, " . template . ", not found");
			}
			
			// Read the template lines.
			var commands = file(template);
			if (empty(commands)) {
				return;
			}

			if (empty(this->template_dir)) {
				let this->template_dir = dirname(template);
			}

			let this->event_manager = new EventManager();
			let this->database = new Database();

			var parser;
			for parser in this->available {
				let this->parsers[parser] = new {parser}();
			}

			// Process the commands.
			var command = "";

			for command in commands {
				let this->line += 1;

				if (command == "") {
					continue;
				}

				// Process any events.
				let command = this->event_manager->process(command);				
				if (!this->processCommand(command)) {
					let command = this->parseEquation(command);
					if (!empty(command)) {
						let this->output = this->output . "<?php " . command . ";?>";
					}
				}
			}

			return this->output;
		} catch Exception, err {
		    err->fatal(template, this->line);
		} catch \RuntimeException|\Exception, err {
			var newErr;
			let newErr = new Exception(err->getMessage(), err->getCode());

			echo newErr->fatal(template, this->line);
		}
    }

	private function processCommand(string command)
	{
		var parser = "", parsed = "", args, controller;
		let args = new Args();

		// Clean the command of the tabs and the returns.
		var cleaned = trim(command);

		// Output a line break or a new line.
		if (this->match(cleaned, "BENCHMARK")) {
			let this->output = this->output . "<script type=\"text/javascript\">let kb_start_time = " . this->start_time . ";window.onload = function () {document.getElementById(\"kb-benchmark\").innerHTML = ((Date.now() - kb_start_time) / 1000).toFixed(3) + \"s\";}</script><span id=\"kb-benchmark\"></span>";
			return true;
		}

		// SPRINT will ignore the command processing and just output the command as a string.
		if (this->match(cleaned, "SPRINT")) {			
			this->writeOutput(str_replace("SPRINT ","", command));
			return true;
		}

		// REM will ignore the command processing as it is a kytschBASIC comment.
		if (this->match(cleaned, "REM")) {
			return true;
		}

		// INCLUDE to include a library.
		if (this->match(cleaned, "INCLUDE")) {
			var lib = trim(str_replace("INCLUDE ","", command));
			switch (lib) {
				case "arcade":
					var arcade_output;
					let arcade_output = (new Arcade(this->event_manager, this->globals))->build();

					if (arcade_output) {
						let this->arcade = new Arcade(this->event_manager, this->globals);
					}

					this->writeOutput(arcade_output);
					break;
				default:
					break;
			}
			return true;
		}

		// Output a line break or a new line.
		if (this->match(cleaned, "LINE BREAK")) {
			this->writeOutput("<br/>");
			return true;
		}

		// Check to see the command is CPRINT for code printing.
		if (this->processCPrint(cleaned, command)) {
			return true;
		}

		if (this->match(cleaned, "VERSION")) {
			this->writeOutput("<span class=\"kb-version\">" . constant("VERSION") . "</span>");
			return true;
		}

		// Trigger a redirect.
		if (this->match(cleaned, "GOTO")) {
			var url = trim(trim(str_replace("GOTO ","", command)), "\"");
			let this->output = this->output . "<?php header('Location: " . args->clean(url) . "'); ?>";
			return true;
		}

		if (this->match(cleaned, "MAIL CLOSE")) {
			let this->mail = false;
			this->sendMail();
			return true;
		} elseif (this->match(cleaned, "MAIL")) {
			let this->mail = true;
			let this->mail_options["message"] = "";
			this->createMail(cleaned);
			return true;
		}
		
		// Check to see the command is an IF.
		if (this->processIfStatement(cleaned)) {
			return true;
		}

		// Check to see the command is a SELECT/SWITCH.
		if (this->processSelectStatement(cleaned)) {
			return true;
		}

		// Check to see the command is DATA for accessing the database.
		let parsed = this->database->parse(
			cleaned,
			this->event_manager,
			this->globals,
			this->config
		);
		
		if (parsed != null) {
			if (is_string(parsed)) {
				this->writeOutput(parsed);
			}
			return true;
		}

		// Parse the LOAD statement.
		let controller = new Load();
		let parsed = controller->parse(cleaned, this->event_manager, this->globals);
		if (parsed != null) {
			var ext;
			let ext = pathinfo(parsed, PATHINFO_EXTENSION);
			switch (ext) {
				case "js":
					this->writeOutput("<script src='" . parsed . "'></script>");
					break;
				default:
					this->writeOutput(
						(new self())->parse(
							this->parseGlobals(this->globals, rtrim(ltrim(parsed, "/"), ".kb")) . ".kb",
							this->config,
							this->globals,
							this->start_time
						)
					);
					break;
			}			
			return true;
		}

		// Parser the command with available parsers.
		for parser in this->parsers {
			let parsed = parser->parse(cleaned, this->event_manager, this->globals, this->config);
			if (parsed != null) {
				this->writeOutput(parsed);
				return true;
			}
		}

		// If the arcade lib is loaded check for arcade commands.
		if (this->arcade) {
			let parsed = this->arcade->parse(cleaned);
			if (parsed != null) {
				this->writeOutput(parsed);
				return true;
			}
		}

		// END will end the page building.
		if (cleaned == "END") {
			this->writeOutput("</html>");
			return true;
		}

		return false;
	}

	/**
	 * Write to the output to later display to screen or to somewhere else.
	 */
	private function writeOutput(string to_write)
	{	
		if (this->mail) {
			let this->mail_options["message"] .= to_write;
		} else {
			let this->output = this->output . to_write;
		}
	}

	/**
	 * Create the mail options.
	 */
	private function createMail(string line)
	{
		var args, arg, controller;
		let controller = new Args();
		let args = this->parseArgs("MAIL", line);

		if (isset(args[0])) {
			let arg = controller->clean(args[0]);
			if (!empty(arg)) {
				let this->mail_options["to"] = arg;
			}
		}

		if (isset(args[1])) {
			let arg = controller->clean(args[1]);
			if (!empty(arg)) {
				let this->mail_options["subject"] = arg;
			}
		}

		if (isset(args[2])) {
			let arg = controller->clean(args[2]);
			if (!empty(arg)) {
				let this->mail_options["from"] = arg;
			}
		}
	}

	/**
	 * Send the mail using the built up options.
	 */
	private function sendMail()
	{
		if (empty(this->mail_options)) {
			throw new Exception("No mail options defined");
		}

		if (!isset(this->mail_options["to"])) {
			throw new Exception("Invalid to setting for MAIL");
		}

		var additional_headers = [];

		let additional_headers["from"] = this->mail_options["from"];
		
		if (!mail(
			this->mail_options["to"],
			this->mail_options["subject"],
			this->mail_options["message"],
			additional_headers
		)) {
			var err, msg;

			let msg = "Failed to send the mail";

			let err = error_get_last();
			if (isset(err["message"])) {
				let msg .= ", " . err["message"];
			}
			
			throw new Exception(msg);
		}
	}

	/**
	 * Process the CPRINT command.
	 * This is used to display the code rather than parse it.
	 */
	private function processCPrint(string cleaned, string command)
	{
		if (this->match(cleaned, "CPRINT CLOSE")) {
			let this->output = this->output . "</code></pre>";
			let this->cprinting = false;
			return true;
		}

		if (this->match(cleaned, "CPRINT")) {
			let this->output = this->output . "<pre><code>";
			let this->cprinting = true;
			return true;
		}

		/**
		 * Code printing so just output the command instead of parsing.
		 */
		if (this->cprinting) {
			let this->output = this->output . command;
			return true;
		}

		return false;
	}

	/**
	 * Process the any IF statements.
	 */
	 private function processIfStatement(var line) {
		var args;
				
		if (this->match(line, "END IF")) {
			let this->output = this->output . "<?php } ?>";
			return true;
		} elseif (this->match(line, "ELSEIF")) {
			let args = this->parseSpaceArgs(line, "ELSEIF");
			
			if (count(args) > 2) {
				if (args[1] == "THEN") {
					this->processIfThen(args, 2, true);
				} elseif(isset(args[3])) {
					if (args[3] == "THEN") {
						this->processIfThen(args, 4, true);
					} 
				}
				return true;
			} elseif (count(args) >= 1 && count(args) <= 2) {
				if (substr_count(args[0], "=") == 1) {
					let args[0] = str_replace("=", "==", args[0]);
				}
				if (!this->isVar(args[0])) {
					let args[0] = this->cleanArg(args[0]);
				} else {
					let args[0] = this->parseVar(args[0]);
				}
				let this->output = this->output . "<?php } elseif(" . args[0] . ") { ?>";
				return true;
			}

			throw new Exception("Invalid ELSEIF statement");
		} elseif (this->match(line, "ELSE")) {
			let this->output = this->output . "<?php } else { ?>";
			return true;
		} elseif (this->match(line, "IFNTE")) {
			let args = this->parseSpaceArgs(line, "IFNTE");
			
			if (count(args) > 2) {				
				if (args[1] == "THEN") {
					this->processIfThen(args);
				} elseif(isset(args[3])) {
					if (args[3] == "THEN") {
						this->processIfThen(args, 4);
					} 
				}
				return true;
			} elseif (count(args) >= 1 && count(args) <= 2) {
				if (substr_count(args[0], "=") == 1) {
					let args[0] = str_replace("=", "==", args[0]);
				}

				if (!this->isVar(args[0])) {
					let args[0] = this->cleanArg(args[0]);
				} else {
					let args[0] = this->parseVar(args[0]);
				}
				let this->output = this->output . "<?php if(!empty(" . args[0] . ")) { ?>";
				return true;
			}

			throw new Exception("Invalid IFNTE statement");
		} elseif (this->match(line, "IF")) {
			let args = this->parseSpaceArgs(line, "IF");

			if (count(args) > 2) {				
				if (args[1] == "THEN") {
					this->processIfThen(args);
				} elseif(isset(args[3])) {
					if (args[3] == "THEN") {
						this->processIfThen(args, 4);
					} 
				}
				return true;
			} elseif (count(args) >= 1 && count(args) <= 2) {
				let args[0] = args[0];

				if (substr_count(args[0], "=") == 1) {
					let args[0] = str_replace("=", "==", args[0]);
				}

				if (!this->isVar(args[0])) {
					let args[0] = this->cleanArg(args[0]);
				} else {
					let args[0] = this->parseVar(args[0]);
				}

				let this->output = this->output . "<?php if(" . args[0] . ") { ?>";
				return true;
			}

			throw new Exception("Invalid IF statement");
		}

		return false;
	}

	private function processIfThen(
		var args,
		var start = 2,
		boolean else_if = false
	) {
		var if_statement, command = "if";

		if (else_if) {
			let command = "} elseif";
		}

		var line = implode(" ", array_slice(args, start, count(args) - start));		

		if (start == 4) {
			let if_statement = args[0] . " " . args[1] . " " . args[2];
		} else {
			let if_statement = args[0];
		}

		if (substr_count(if_statement, "=") == 1) {
			let if_statement = str_replace("=", "==", if_statement);
		}

		if (!this->isVar(if_statement)) {
			let if_statement = this->cleanArg(if_statement);
		} else {
			let if_statement = this->parseVar(if_statement);
		}

		let this->output = this->output . "<?php " . command . "(" . if_statement . ") { ?>";

		if (line) {
			if (!this->processCommand(line)) {
				var maths, text;
				let maths = new Maths();
				let text = new Text();
				let this->output = this->output . "<?php " . maths->commands(text->commands(line)) . "?>";
			}
		}
	}

	/**
	 * Process the any SELECT statements.
	 */
	 private function processSelectStatement(var line) {
		var args, sym = "$";
				
		if (this->match(line, "END SELECT")) {
			if (this->select_started > 1) {
				let this->output = this->output . "<?php break; ?>";
			}
			let this->select_started = 0;
			let this->output = this->output . "<?php } ?>";
			return true;
		} elseif (this->match(line, "DEFAULT")) {
			if (this->select_started > 1) {
				let this->output = this->output . "<?php break; ?>";
			}
			let this->output = this->output . "<?php default: ?>";
			return true;
		} elseif (this->match(line, "CASE")) {
			let args = this->parseSpaceArgs(line, "CASE");
			
			if (count(args) == 1) {
				if (this->select_started > 1) {
					let this->output = this->output . "<?php break; ?>";
				}
				let this->output = this->output . "<?php case " . args[0] . ": ?>";
				let this->select_started = this->select_started + 1;
				return true;
			}

			throw new \Exception("Invalid CASE statement");
		} elseif (this->match(line, "SELECT")) {
			let this->select_started = 1;
			let args = this->parseSpaceArgs(line, "SELECT");
						
			if (count(args) == 1) {
				if (substr(args[0], 0, 6) == "_VALID") {
					let sym = "";
				}
				let this->output = this->output . "<?php switch(" . sym . args[0] . ") { ?>";
				return true;
			}

			throw new \Exception("Invalid SELECT statement");
		}

		return false;
	}
}
