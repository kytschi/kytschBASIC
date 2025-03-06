/**
 * Text parser
 *
 * @package     KytschBASIC\Parsers\Core\Text\Text
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
namespace KytschBASIC\Parsers\Core\Text;

use KytschBASIC\Parsers\Core\Command;

class Text extends Command
{
	public function parse(string command, string args)
	{
		if (command == "PRINT") {
			return this->processPrint(args);
		} elseif (command == "END SWRITE") {
			return "</p>";
		} elseif (command == "SWRITE") {
			return this->processSWrite(args);
		} elseif (command == "LINE BREAK") {
			return "<br/>";
		}

		return null;
	}

	private function processCentre(args)
	{
		var value="";

		let args = this->args(args);
		let value = this->setArg(args[0]);

		if (isset(args[1])) {
			let value = substr(
				value,
				(strlen(value) / 2) - 1,
				intval(args[1])
			);
		}

		return "\"" . value . "\"";
	}

	private function processPrint(args)
	{
		var value="", splits, output = "<?= \"<span", converted, length=1;

		let args = this->args(args);
		
		if (substr(args[0], 0, 3) == "INT") {
			let args[0] = trim(str_replace("INT", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid INT");
			}

			let value = "\" . intval(\"" . this->setArg(args[0], false) . "\") . \"";
		} elseif (substr(args[0], 0, 3) == "CHR") {
			let args[0] = trim(str_replace("CHR", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid CHR");
			}

			let value = "\" . chr(intval(\"" . this->setArg(args[0], false) . "\")) . \"";
		} elseif (substr(args[0], 0, 6) == "STRING") {
			let args[0] = trim(str_replace("STRING", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid STRING");
			}
						
			let converted = this->setArg(args[0]);
			array_shift(args);
			
			if (isset(args[0])) {
				if (is_numeric(args[0])) {
					let length = intval(args[0]);
				}
			}

			while length {
				let value .= converted;
				let length -= 1;
			}
		} elseif (substr(args[0], 0, 9) == "STRIPLEAD") {
			let args[0] = trim(str_replace("STRIPLEAD", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid STRIPLEAD");
			}
						
			let converted = this->setArg(args[0]);
			array_shift(args);
			
			var strip_char = "";
			if (isset(args[0])) {
				let value = this->setArg(args[0]);
				let strip_char = "is_numeric(\"" . value . "\") ? chr(intval(\"" . value . "\")) : \"" . value . "\"";
			}

			let value = "\" . ltrim(\"" . converted . "\", " . strip_char . ") . \"";
		} elseif (substr(args[0], 0, 3) == "STR") {
			let args[0] = trim(str_replace("STR", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid STR");
			}

			let value = "\" . (string)\"" . trim(this->setArg(args[0], false), "\"") . "\" . \"";
		} elseif (substr(args[0], 0, 3) == "ASC") {
			let args[0] = trim(str_replace("ASC", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid ASC");
			}

			let value = "\" . ord(\"" . this->setArg(args[0]) . "\") . \"";
		} elseif (substr(args[0], 0, 5) == "LCASE") {
			let args[0] = trim(str_replace("LCASE", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid LCASE");
			}

			let value = "\" . strtolower(\"" . this->setArg(args[0]) . "\") . \"";
		} elseif (substr(args[0], 0, 3) == "LEN") {
			let args[0] = trim(str_replace("LEN", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid LEN");
			}

			let value = "\" . strlen(\"" . this->setArg(args[0]) . "\") . \"";
		} elseif (substr(args[0], 0, 4) == "LSET") {
			let args[0] = trim(str_replace("LSET", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid LSET");
			}

			let converted = this->setArg(args[0]);
			array_shift(args);
			
			if (isset(args[0])) {
				if (is_numeric(args[0])) {
					let length = intval(args[0]);
				}
			}
						
			let value = "\" . (new KytschBASIC\\Parsers\\Core\Text\\Text())->processPadding(\"" . converted . "\", intval(" . length . "), 'left') . \"";
		} elseif (substr(args[0], 0, 4) == "RSET") {
			let args[0] = trim(str_replace("RSET", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid RSET");
			}

			let converted = this->setArg(args[0]);
			array_shift(args);
			
			if (isset(args[0])) {
				if (is_numeric(args[0])) {
					let length = intval(args[0]);
				}
			}
						
			let value = "\" . (new KytschBASIC\\Parsers\\Core\Text\\Text())->processPadding(\"" . converted . "\", intval(" . length . ")) . \"";
		} elseif (substr(args[0], 0, 6) == "CENTRE") {
			let args[0] = trim(str_replace("CENTRE", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid CENTRE");
			}

			let converted = this->setArg(args[0]);
			array_shift(args);
			
			if (isset(args[0])) {
				if (is_numeric(args[0])) {
					let length = intval(args[0]);
				}
			}
			let value = "\" . substr(\"" . converted . "\", intval(strlen(\"" . converted . "\") / 2) - 1, intval(" . length . ")) . \"";
		} elseif (substr(args[0], 0, 4) == "LEFT") {
			let args[0] = trim(str_replace("LEFT", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid LEFT");
			}

			let converted = this->setArg(args[0]);
			array_shift(args);
			
			if (isset(args[0])) {
				if (is_numeric(args[0])) {
					let length = intval(args[0]);
				}
			}
			let value = "\" . substr(\"" . converted . "\", 0,  intval(" . length . ")) . \"";
		} elseif (substr(args[0], 0, 5) == "RIGHT") {
			let args[0] = trim(str_replace("RIGHT", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid RIGHT");
			}

			let converted = this->setArg(args[0]);
			array_shift(args);
			
			if (isset(args[0])) {
				if (is_numeric(args[0])) {
					let length = intval(args[0]);
				}
			}
			let value = "\" . substr(\"" . converted . "\", intval(strlen(\"" . converted . "\")) - intval(" . length . "),  intval(" . length . ")) . \"";
		}elseif (substr(args[0], 0, 3) == "MID") {
			let args[0] = trim(str_replace("MID", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid MID");
			}
						
			var start=0, end=1;
			let converted = this->setArg(args[0]);
			array_shift(args);
			
			if (isset(args[0])) {
				if (is_numeric(args[0])) {
					let start = intval(args[0]);
				}
			}

			if (isset(args[1])) {
				if (is_numeric(args[1])) {
					let end = intval(args[1]);
					unset(args[1]);
				}
			}

			let value = "\" . substr(\"" . converted . "\", " . (start - 1) . ", " . end . ") . \"";
		} elseif (substr(args[0], 0, 7) == "REPLACE") {
			let args[0] = trim(str_replace("REPLACE", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid REPLACE");
			}
						
			var find="", replace="";
			let converted = this->setArg(args[0]);
			array_shift(args);
			
			if (isset(args[0])) {
				let find = this->setArg(args[0]);
				array_shift(args);
			}

			if (isset(args[0])) {
				let replace = this->setArg(args[0]);
			}
			
			let value = "\" . str_replace(\"" . find . "\", \"" . replace . "\", \"" . converted . "\") . \"";
		} elseif (substr(args[0], 0, 5) == "INSTR") {
			let args[0] = trim(str_replace("INSTR", "", args[0]));

			if (args[0] != "0" && empty(args[0])) {
				throw new \Exception("Invalid INSTR");
			}
			
			let args[0] = splits[1];
			
			var haystack = "", needle = "";
			
			let haystack = this->setArg(args[0]);
			array_shift(args);

			if (isset(args[0])) {
				let needle = this->setArg(args[0]);
			}

			let value = "\" . strpos(\"" . haystack . "\", \"" . needle . "\") . \"";
		} else {
			let value = trim(this->setArg(args[0], false), "\"");
		}

		if (isset(args[1])) {
			let output .= " class='" . this->setArg(args[1]) . "'";
		}

		if (isset(args[2])) {
			let output .= " id='" . this->setArg(args[2]) . "'";
		} else {
			let output .= " id='" . this->genID("kb-span") . "'";
		}
		
		return output . ">" . value . "</span>\";?>";
	}

	public function processPadding(string text, int length, string dir = "right")
	{
		var spaces="", end;

		if (length > strlen(text)) {
			let end = length - strlen(text);
			
			while end {
				let spaces .= "&nbsp;";
				let end -= 1;
			}
		}

		return (dir == "left" ? spaces : "") . substr(text, 0, length) . (dir == "right" ? spaces : "");
	}

	private function processSWrite(args)
	{
		var params="";

		let args = this->args(args);
		
		if (isset(args[0]) && !empty(args[0])) {
			let params .= " class='" . this->setArg(args[0]) . "'";
		}

		if (isset(args[1]) && !empty(args[1])) {
			let params .= " id='" . this->setArg(args[1]) . "'";
		} else {
			let params .= " id='" . this->genID("kb-span") . "'";
		}
		
		return "<?= \"<p" . params . ">\"; ?>";
	}
}
