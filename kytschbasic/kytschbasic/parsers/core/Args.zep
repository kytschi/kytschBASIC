/**
 * Args parser
 *
 * @package     KytschBASIC\Parsers\Core\Args
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
namespace KytschBASIC\Parsers\Core;

use KytschBASIC\Exceptions\ConfigException;

class Args
{
	public function add(args, string html)
	{
		if (empty(args)) {
			return html;
		}

		var key, arg = "";

		for key, arg in args {
			let html = html . " " . key . "=\"" . trim(arg, "\"") . "\"";
		}

		return html;
	}

	public function clean(string arg, var config = null)
	{
		let arg = trim(trim(arg), "\"");

		var vars, iLoop, param, splits, key, replace;

		preg_match_all("|_POST[^\]]+\]|U", arg, vars);
		if (count(vars[0])) {
			let iLoop = count(vars[0]);
			while iLoop {
				let iLoop -= 1;

				let param = urldecode(vars[0][iLoop]);
				let splits = explode("\"", param);
				let key = trim(splits[1], "\"");

				let replace = "";
				if (isset(_POST[key])) {
					let replace = _POST[key];
				}
								
				let arg = str_replace(param, replace, arg);
			}
		}

		preg_match_all("|_GET[^\]]+\]|U", arg, vars);
		if (count(vars[0])) {
			let iLoop = count(vars[0]);
			while iLoop {
				let iLoop -= 1;

				let param = urldecode(vars[0][iLoop]);
				let splits = explode("\"", param);
								
				let replace = "";
				if (isset(_GET[key])) {
					let replace = _GET[key];
				}
								
				let arg = str_replace(param, replace, arg);
			}
		}

		preg_match_all("|_REQUEST[^\]]+\]|U", arg, vars);
		if (count(vars[0])) {
			let iLoop = count(vars[0]);
			while iLoop {
				let iLoop -= 1;

				let param = urldecode(vars[0][iLoop]);
				let splits = explode("\"", param);
								
				let replace = "";
				if (isset(_REQUEST[key])) {
					let replace = _REQUEST[key];
				}
								
				let arg = str_replace(param, replace, arg);
			}
		}

		preg_match_all("|ENCRYPT[^\)]+\)|U", arg, vars);
		if (count(vars[0])) {
			let iLoop = count(vars[0]);
			while iLoop {
				let iLoop -= 1;

				let param = str_replace("ENCRYPT(", "", (vars[0][iLoop]));
												
				let replace = "";
				if (empty(config["security"])) {
					throw new ConfigException("security config is missing");
				} elseif (!property_exists(config["security"], "public_key")) {
					throw new ConfigException("public key is missing from the security config");
				}
				
				// Temp surpress the warnings about the IV.
				var errors = false, log_errors = false;
				if (ini_get("display_errors")) {
					ini_set("display_errors", "0");
					let errors = true;
				}

				if (ini_get("log_errors")) {
					ini_set("log_errors", "0");
					let log_errors = true;
				}

				// Encrypt the data using the supplied public key.
				let replace = openssl_encrypt(
					rtrim(param, ")"),
					"aes128",
					file_get_contents(getcwd() . config["security"]->public_key)
				);

				// Restore warning output.
				if (errors) {
					ini_set("display_errors", "1");
				}

				if (log_errors) {
					ini_set("log_errors", "1");
				}
								
				let arg = str_replace("ENCRYPT(" . param, replace, arg);
			}
		}

		return arg;
	}

	public function leftOver(int start, args)
	{
		var bits, value, params = "";
		let args = array_slice(args, start, count(args) - start);

		for value in args {
			let bits = explode("$=", value);
			if (count(bits) == 1) {
				continue;
			}

			let params = params . " " . bits[0] . "=\"" . this->clean(bits[1]) . "\"";
		}

		return params;
	}

	public function parse(
		string command,
		string line,
		array globals = []
	) {
		var args = [], arg = "";

		var splits = preg_split(
			"/\w*,/",
			trim(substr(line, strlen(command), strlen(line)))
		);

		if (empty(splits)) {
			return args;
		}

		for arg in splits {
			var bits = [];
			let bits = explode("$=\"", rtrim(trim(arg), "\""));

			if (count(bits) == 1) {
				continue;
			}

			if (bits[0] == "rgb") {
				var colours, colour, key;
				let colours = explode(",", bits[1]);
				let args[bits[0]] = [];

				let args[bits[0]]["red"] = 0;
				let args[bits[0]]["green"] = 0;
				let args[bits[0]]["blue"] = 0;

				for key, colour in colours {
					if (key == 0) {
						let args[bits[0]]["red"] = intval(trim(colour, "\""));
					} elseif (key == 1) {
						let args[bits[0]]["green"] = intval(trim(colour, "\""));
					} elseif (key == 2) {
						let args[bits[0]]["blue"] = intval(trim(colour, "\""));
					}
				}

				continue;
			} elseif (bits[0] == "transparency") {
				var percent;
				let percent = intval(bits[1]) / 100;
				if (percent != 0) {
					let args[bits[0]] = percent * 127;
				} else {
					let args[bits[0]] = 0;
				}

				continue;
			}

			let args[bits[0]] = this->processGlobals(bits[1], globals);
		}

		return args;
	}

	public function parseShort(
		string command,
		string line
	) {
		var key, value, splits = [], comma_code = base64_encode(microtime());

		let line = trim(substr_replace(line, "", 0, strlen(command)));

		if (line == "," || line == "\",\"" || empty(line)) {
			let splits[] = line;
			return splits;
		}

		let line = preg_replace_callback(
			"/(\"[^\",]+),([^\"]+\")/",
			function (matches) use (comma_code) {
				return str_replace(",", comma_code, matches[0]);
			},
			line
		);

		let splits = explode(",", line);

		if (strpos(line, comma_code) === false) {
			return splits;
		}

		for key, value in splits {
			let splits[key] = str_replace(comma_code, ",", value);
		}

		return splits;
	}

	public function process(
		string command,
		string line,
		string tag,
		array globals = []
	) {
		return this->add(
			this->parse(command, line, globals),
			"<" . tag
		) . ">";
	}

	public function processGlobals(
		string str,
		array globals = []
	) {
		if (strpos(str, "_ROOT") !== false) {
			let str = str_replace("_ROOT", globals["_ROOT"], str);
		}

		return str;
	}

	public function transparency(value)
	{
		var percent;
		let percent = intval(value) / 100;
		if (percent != 0) {
			return intval(percent * 127);
		} else {
			return 0;
		}
	}

	public function value(
		string command,
		string line
	) {
		var splits = explode("\", ", line);
		if (count(splits) > 1) {
			return splits[count(splits) - 1];
		}

		return str_replace(command . " ", "", line);
	}
}
