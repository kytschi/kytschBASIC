/**
 * Cookie parser
 *
 * @package     KytschBASIC\Parsers\Core\Storage\Cookie
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
namespace KytschBASIC\Parsers\Core\Storage;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Cookie extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch (command) {
			case "CREATECOOKIE":
				return this->processCreate(args);
			case "WRITECOOKIE":
				return this->processWrite(args);
			default:
				return null;
		}
	}

	public function processCreate(args)
	{
		var data = "KYTSCHBASIC", output = "<?php setcookie(\"";

		if (count(args) == 1) {
			let args[0] = rtrim(ltrim(args[0], "["), "]");
			let args = this->commaSplit(args[0]);
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let data = trim(args[1], "\"");
		}
	
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			if (substr(data, 0, 1) != "$") {
				let data = "\"" . data . "\"";
			}
			let output .= trim(args[0], "\"") . "\", (!is_string(" . data . ") ? ";
			let output .= "json_encode(" . data . ") : " . data . ")";
		} else {
			throw new Exception("Invalid CREATECOOKIE, missing cookie name");
		}

		return output . "); ?>";
	}

	public function processRead(line)
	{
		var splits, args, cleaned = "", var_name = "", data = "";

		let splits = this->equalsSplit(line);
		if (count(splits) <= 1) {
			throw new Exception("Invalid READCOOKIE");
		}

		let cleaned = this->cleanArg("READCOOKIE", splits[1]);
		let cleaned = rtrim(ltrim(cleaned, "["), "]");
		
		let args = this->commaSplit(cleaned);

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let var_name = trim(args[1], "\"");
		}

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let data = this->readCookie(args[0]);
						
			if (var_name && isset(data[var_name])) {
				let data = data[var_name];
			}

			if (is_string(data)) {
				let data = "\"" . data . "\"";
			}
		} else {
			throw new Exception("Invalid READCOOKIE, missing cookie name");
		}

		return str_replace(
			splits[1],
			data,
			line,
			1
		); 
	}

	public function processWrite(args)
	{
		var data, var_name = "", output = "<?php ";

		/*if (count(args) == 1) {
			let args[0] = rtrim(ltrim(args[0], "["), "]");
			let args = this->commaSplit(args[0]);
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let var_name = trim(args[1], "\"");
		}

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let data = this->readCookie(args[0], false);
			let output .= "setcookie(\"";

			if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
				if (var_name && isset(data[var_name])) {
					let data[var_name] = trim(args[2], "\"");
				} else {
					let data = trim(args[2], "\"");
				}

				if (substr(data, 0, 1) != "$") {
					let data = "\"" . data . "\"";
				}
				let output .= trim(args[0], "\"") . "\", (!is_string(" . data . ") ? ";
				let output .= "json_encode(" . data . ") : " . data . ")";
			}
		}  else {
			throw new Exception("Invalid WRITECOOKIE, missing cookie name");
		}*/

		return output . " ?>";
	}

	public function readCookie(string name, bool read = true)
	{
		var data;

		let name = trim(name, "\"");
			
		if (!isset(_COOKIE[name])) {
			throw new Exception("Invalid " . (read ? "READCOOKIE" : "WRITECOOKIE") . ", cookie not found");
		}

		let data = json_decode(_COOKIE[name], true);
		if (data === null) {
			let data = _COOKIE[name];
		}

		return data;
	}
}
