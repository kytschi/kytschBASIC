/**
 * Cookie parser
 *
 * @package    
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
				return this->processWrite(args, in_javascript);
			default:
				return null;
		}
	}

	public function processCreate(args)
	{
		var data = "KYTSCHBASIC", cookie_name, output = "<?php setcookie(";

		if (count(args) == 1) {
			let args[0] = rtrim(ltrim(args[0], "["), "]");
			let args = this->commaSplit(args[0]);
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let data = trim(args[1], "\"");
		}
	
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let cookie_name = trim(args[0], "\"");
			if (substr(cookie_name, 0, 1) != "$") {
				let cookie_name = "\"" . cookie_name . "\"";
			}

			if (substr(data, 0, 1) != "$") {
				let data = "\"" . data . "\"";
			}

			let output .= cookie_name . ", (!is_string(" . data . ") ? ";
			let output .= "json_encode(" . data . ") : " . data . ")";
		} else {
			throw new Exception("Invalid CREATECOOKIE, missing cookie name");
		}

		return output . "); ?>";
	}

	public function processRead(line)
	{
		var splits, args, cleaned = "", var_name = "", data = "", cookie_name;

		let splits = this->equalsSplit(line);
		if (count(splits) <= 1) {
			throw new Exception("Invalid READCOOKIE");
		}

		let cleaned = this->cleanArg("READCOOKIE", splits[1]);
		let cleaned = rtrim(ltrim(cleaned, "["), "]");
		
		let args = this->commaSplit(cleaned);

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let var_name = trim(args[1], "\"");
			if (substr(var_name, 0, 1) != "$") {
				let var_name = "\"" . var_name . "\"";
			}
		}

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let cookie_name = trim(args[0], "\"");
			if (substr(cookie_name, 0, 1) != "$") {
				let cookie_name = "\"" . cookie_name . "\"";
			}
			
			let data = "(!isset($_COOKIE[" . cookie_name . "]) ? '' : ";
			let data .= "(($KBCOOKIETMP = json_decode($_COOKIE[" . cookie_name . "], true)) ? ";
			let data .= "(isset($KBCOOKIETMP[" . var_name . "]) ? $KBCOOKIETMP[" . var_name . "] : null) : ";
			let data .= "$_COOKIE[" . cookie_name . "]))";
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

	public function processWrite(args, bool in_javascript = false)
	{
		var var_name = "", output = "<script type=\"text/javascript\">";

		if (in_javascript) {
			let output = "";
		}

		if (count(args) == 1) {
			let args[0] = rtrim(ltrim(args[0], "["), "]");
			let args = this->commaSplit(args[0]);
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let var_name = trim(args[2], "\"");
			if (substr(var_name, 0, 1) != "$") {
				let var_name = "\"" . var_name . "\"";
			}
			else {
				let var_name = "\"<?= " . var_name . "; ?>\"";
			}
		}

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let args[0] = trim(args[0], "\"");
			if (substr(args[0], 0, 1) != "$") {
				let args[0] = "\"" . args[0] . "\"";
			} else {
				let args[0] = "\"<?= " . args[0] . "; ?>\"";
			}

			if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
				let args[1] = trim(args[1], "\"");
				if (substr(args[1], 0, 1) != "$") {
					let args[1] = "\"" . args[1] . "\"";
				} else {
					let args[1] = "\"<?= " . args[1] . "; ?>\"";
				}
			}

			let output .= "\tWRITECOOKIE(" . args[0] . ", " . args[1] . ", " . var_name . ");\n";
		}  else {
			throw new Exception("Invalid WRITECOOKIE, missing cookie name");
		}

		return output . (in_javascript ? "" : "</script>");
	}
}
