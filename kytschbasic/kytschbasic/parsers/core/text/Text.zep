/**
 * Text parser
 *
 * @package     KytschBASIC\Parsers\Core\Text
 * @author 		Mike Welsh
 * @copyright   2022 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2022 Mike Welsh
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
namespace KytschBASIC\Parsers\Core\Text;

use KytschBASIC\Events\LineBreakEvent;
use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Maths;
use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Session;

class Text extends Command
{
	protected static id = "";
	protected static _class = "";

	public static function commands(
		string command,
		boolean add_qoutes = false
	) {
		var matches, key, found, replace, splits, iLoop, haystack;

		preg_match_all(
			"/LCASE\\$\(\"(.*?)\"\)|UCASE\\$\(\"(.*?)\"\)|INT\((.*?)\)|CHR\\$\((.*?)\)|ASC\(\"(.*?)\"\)|STRING\\$\((.*?)\)|LEFT\\$\((.*?)\)|RIGHT\\$\((.*?)\)|MID\\$\((.*?)\)|INSTR\\$\((.*?)\)|REPLACE\\$\((.*?)\)|LEN\((.*?)\)|UNLEFT\\$\((.*?)\)|UNRIGHT\\$\((.*?)\)|STRIPLEAD\\$\((.*?)\)|STRIPTRAIL\\$\((.*?)\)|LSET\\$\((.*?)\)|RSET\\$\((.*?)\)|CENTRE\\$\((.*?)\)|VAL\((.*?)\)|STR\\$\((.*?)\)/",
			command,
			matches
		);

		if (count(matches[0]) == 0) {
			return command;
		}

		for key, found in matches[0] {
			if (strpos(found, "LCASE$(") !== false) {
				let replace = strtolower(matches[1][key]);
			} elseif (strpos(found, "UCASE$(") !== false) {
				let replace = strtoupper(matches[2][key]);
			} elseif (strpos(found, "INT(") !== false) {
				let replace = intval(matches[3][key]);
			} elseif (strpos(found, "CHR$(") !== false) {
				let replace = chr(matches[4][key]);
			} elseif (strpos(found, "ASC(") !== false) {
				let replace = ord(matches[5][key]);
			} elseif (strpos(found, "STRING$(") !== false) {
				let splits = explode("\",", matches[6][key]);
				if (count(splits) > 1) {
					let iLoop = intval(splits[1]);
					let replace = "";

					while iLoop {
						let replace = replace . trim(splits[0], "\"");
						let iLoop -= 1;
					}
				} else {
					let replace = trim(matches[6][key], "\"");
				}
			} elseif (strpos(found, "UNLEFT$(") !== false) {
				let splits = explode("\",", matches[13][key]);

				if (count(splits) == 2) {
					let replace = substr_replace(
						trim(trim(splits[0]), "\""),
						"",
						0,
						intval(trim(trim(splits[1]), "\"")) - 1
					);
				} else {
					let replace = trim(matches[13][key], "\"");
				}
			} elseif (strpos(found, "UNRIGHT$(") !== false) {
				let splits = explode("\",", matches[14][key]);

				if (count(splits) == 2) {
					let replace = substr_replace(
						trim(trim(splits[0]), "\""),
						"",
						strlen(trim(trim(splits[0]), "\"")) - intval(trim(trim(splits[1]), "\"")),
						strlen(trim(trim(splits[0]), "\""))
					);
				} else {
					let replace = trim(matches[14][key], "\"");
				}
			} elseif (strpos(found, "LEFT$(") !== false) {
				let splits = explode("\",", matches[7][key]);
				if (count(splits) > 1) {
					let replace = substr(trim(splits[0], "\""), 0, intval(splits[1]) - 1);
				} else {
					let replace = trim(matches[7][key], "\"");
				}
			} elseif (strpos(found, "RIGHT$(") !== false) {
				let splits = explode("\",", matches[8][key]);
				if (count(splits) > 1) {
					let replace = substr(trim(splits[0], "\""), -1 * intval(splits[1]));
				} else {
					let replace = trim(matches[8][key], "\"");
				}
			} elseif (strpos(found, "MID$(") !== false) {
				let splits = explode("\",", matches[9][key]);
				if (count(splits) > 2) {
					let replace = substr(trim(splits[0], "\""), intval(splits[1]) - 1, intval(splits[2]));
				} else {
					let replace = trim(matches[9][key], "\"");
				}
			} elseif (strpos(found, "INSTR$(") !== false) {
				let splits = explode("\",", matches[10][key]);
				if (count(splits) > 1) {
					var start = 0;
					if (isset(splits[2])) {
						let start = splits[2];
					}

					let replace = strpos(trim(splits[0], "\""), trim(trim(splits[1]), "\""), intval(start));
					if (replace === false) {
						let replace = 0;
					} else {
						let replace += 1;
					}
				} else {
					let replace = trim(matches[10][key], "\"");
				}
			} elseif (strpos(found, "REPLACE$(") !== false) {
				let splits = explode("\",", matches[11][key]);
				if (count(splits) == 3) {
					let replace = str_replace(
						trim(trim(splits[1]), "\""),
						trim(trim(splits[2]), "\""),
						trim(trim(splits[0]), "\"")
					);
				} else {
					let replace = trim(matches[11][key], "\"");
				}
			} elseif (strpos(found, "LEN(") !== false) {
				let replace = strlen(trim(matches[12][key], "\""));
			} elseif (strpos(found, "STRIPLEAD$(") !== false) {
				let splits = explode("\",", matches[15][key]);

				if (count(splits) == 2) {
					var strip_char = trim(trim(splits[1]), "\"");
					if (is_numeric(strip_char)) {
						let strip_char = chr(strip_char);
					}
					let replace = ltrim(trim(trim(splits[0]), "\""), strip_char);
				} else {
					let replace = trim(matches[15][key], "\"");
				}
			} elseif (strpos(found, "STRIPTRAIL$(") !== false) {
				let splits = explode("\",", matches[16][key]);

				if (count(splits) == 2) {
					var strip_char = trim(trim(splits[1]), "\"");
					if (is_numeric(strip_char)) {
						let strip_char = chr(strip_char);
					}
					let replace = rtrim(trim(trim(splits[0]), "\""), strip_char);
				} else {
					let replace = trim(matches[16][key], "\"");
				}
			} elseif (strpos(found, "LSET$(") !== false) {
				let splits = explode("\",", matches[17][key]);

				if (count(splits) == 2) {
					let haystack = trim(splits[0], "\"");
					let replace = substr(
						haystack,
						0,
						intval(splits[1])
					);

					if (strlen(haystack) < intval(splits[1])) {
						let iLoop = intval(splits[1]) - strlen(haystack);
						while iLoop {
							let iLoop -= 1;
							let replace = replace . "&nbsp;";
						}
					}
				} else {
					let replace = trim(matches[17][key], "\"");
				}
			} elseif (strpos(found, "RSET$(") !== false) {
				let splits = explode("\",", matches[18][key]);

				if (count(splits) == 2) {
					let haystack = trim(splits[0], "\"");

					if (strlen(haystack) < intval(splits[1])) {
						let iLoop = intval(splits[1]) - strlen(haystack);
						let replace = haystack;
						while iLoop {
							let iLoop -= 1;
							let replace = "&nbsp;" . replace;
						}
					} else {
						let replace = substr(haystack, -1 * intval(splits[1]));
					}
				} else {
					let replace = trim(matches[18][key], "\"");
				}
			} elseif (strpos(found, "CENTRE$(") !== false) {
				let splits = explode("\",", matches[19][key]);

				if (count(splits) == 2) {
					let haystack = trim(splits[0], "\"");

					let replace = substr(
						haystack,
						(strlen(haystack) / 2) - 1,
						intval(splits[1])
					);
				} else {
					let replace = trim(matches[19][key], "\"");
				}
			} elseif (strpos(found, "VAL(") !== false) {
				let replace = sprintf("%d", trim(matches[20][key], "\""));
			} elseif (strpos(found, "STR$(") !== false) {
				let replace = sprintf("%s", trim(matches[21][key], "\""));
			}

			if (add_qoutes) {
				let replace = "\"" . replace . "\"";
			}
			let command = str_replace(found, replace, command);
		}

		return command;
	}

	public static function parse(
		string line,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (self::match(line, "LCASE")) {
			return strtolower(trim(str_replace("LCASE", "", line), "\""));
		} elseif (self::match(line, "UCASE")) {
			return strtoupper(trim(str_replace("UCASE", "", line), "\""));
		} elseif (self::match(line, "TAB")) {
			return self::output("&nbsp;&nbsp;&nbsp;&nbsp;" . trim(str_replace("TAB", "", line), "\""));
		} elseif (self::match(line, "PRINT")) {
			return self::processPrint(line, event_manager, globals);
		} elseif (self::match(line, "SWRITE CLOSE")) {
			return self::output("</p>");
		} elseif (self::match(line, "SWRITE")) {
			return self::processSWrite(line, event_manager, globals);
		} elseif (self::match(line, "WHITESPACE")) {
			return self::processWhitespace(line, event_manager, globals);
		}

		return null;
	}

	private static function processPrint(
		line,
		event_manager,
		array globals
	) {
		var args, arg, params="", value="";

		let self::id = self::genID("kb-span");

		let line = self::commands(line, true);
		let line = Maths::commands(line, true);

		let args = self::parseArgs("PRINT", line);

		if (isset(args[0])) {
			let value = args[0];

			if (self::match(value, "FGET")) {
				var param = str_replace(["FGET[\"", "\"]"], "", value);
				if (isset(_GET[param])) {
					let value = "\"" . _GET[param] . "\"";
				} else {
					let value = "\"\"";
				}
			} elseif (self::match(value, "FPOST")) {
				var param = str_replace(["FPOST[\"", "\"]"], "", value);
				if (isset(_POST[param])) {
					let value = "\"" . _POST[param] . "\"";
				} else {
					let value = "\"\"";
				}
			}

			if (substr(value,0,1) == "\"") {
				let value = "echo '" . self::safe(trim(value, "\"")) . "';";
			} else {
				let value = "echo $" . self::parseEquation(str_replace(["$", "%", "#", "&"], "", value)) . ";";
			}
		}

		if (isset(args[1])) {
			let arg = self::cleanArg(args[1]);
			if (!empty(arg)) {
				let self::_class = arg;
				let params = params ." class=\"" . self::_class . "\"";
			}
		}

		if (isset(args[2])) {
			let arg = self::cleanArg(args[2]);
			if (!empty(arg)) {
				let self::id = arg;
			}
		}

		let params = params . " id=\"" . self::id . "\"";
		let params = params . self::leftOverArgs(2, args);

		return "echo '<span" . params . ">';" . value . "echo '</span>';";
	}


	private static function processSWrite(
		command,
		event_manager,
		array globals
	) {
		var args, arg, params="";

		let self::id = self::genID("kb-p");

		let command = self::commands(command, true);
		let command = Maths::commands(command, true);

		let args = self::parseArgs("SWRITE", command);

		if (isset(args[0])) {
			let arg = self::cleanArg(args[0]);
			if (!empty(arg)) {
				let self::_class = arg;
				let params = params ." class=\"" . self::_class . "\"";
			}
		}

		if (isset(args[1])) {
			let arg = self::cleanArg(args[1]);
			if (!empty(arg)) {
				let self::id = arg;
			}
		}

		let params = params . " id=\"" . self::id . "\"";
		let params = params . self::leftOverArgs(2, args);

		return self::output("<p" . params . ">");
	}

	private static function processWhitespace(
		command,
		event_manager,
		array globals
	) {
		var count=1,output="", args, arg;

		if (isset(args[0])) {
			let arg = self::cleanArg(args[0]);
			if (!empty(arg)) {
				let count = intval(arg);
			}
		}

		var iLoop=0;

		while iLoop < count {
			let output .= "&nbsp;";
			let iLoop += 1;
		}

		return self::output(output);
	}
}
