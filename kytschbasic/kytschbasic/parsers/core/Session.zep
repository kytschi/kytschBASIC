/**
 * Session parser
 *
 * @package     KytschBASIC\Parsers\Core\Session
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.2
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

class Session extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false)
	{
		switch(command) {
			case "SESSCLEAR":
				return self::clear(args);
			case "SESSDESTORY":
				return self::destory();
			case "SESSREAD":
				return self::read(args);
			case "SESSWRITE":
				return self::write(args);
			default:
				return null;
		}
	}

	public static function clear(args)
	{
		var name;

		if (is_array(args)) {
			if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
				let name = args[0];
			} else {
				throw new Exception("Invalid SESSCLEAR");
			}
		} else {
			let name = args;
		}

		if (array_key_exists(trim(name, "\""), _SESSION)) {
			return "<?php unset($_SESSION[" . name . "]); ?>";
		}
	}

	public static function destory()
	{
		return "<?php session_destroy(); ?>";
	}

	public static function read(args)
	{
		var data = null, name;

		if (is_array(args)) {
			if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
				let name = args[0];
			} else {
				throw new Exception("Invalid SESSREAD");
			}

			if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
				let data = args[1];
			} else {
				throw new Exception("Invalid SESSREAD");
			}
		} else {
			let name = args;
		}

		if (array_key_exists(name, _SESSION)) {
			return _SESSION[name];
		}

		return "";
	}

	public static function start()
	{
		if(headers_sent() && session_id()) {
			return;
		}

		var args, name = "kytschBASIC", lifetime = 86400, config, secure = false;
		let config = constant("CONFIG");

		if (isset(config["sesssion"])) {
			if (!empty(config["session"])) {
				if (isset(config["sesssion"]->name)) {
					if(!empty(config["session"]->name)) {
						let name = config["session"]->name;
					}
				}

				if (isset(config["sesssion"]->lifetime)) {
					if(!empty(config["session"]->lifetime)) {
						let lifetime = config["session"]->lifetime;
					}
				}

				if (isset(config["sesssion"]->secure)) {
					if(!empty(config["session"]->secure)) {
						let secure = config["session"]->secure;
					}
				}
			}
		}

		let args = [];
		let args["name"] = name;
		let args["cookie_lifetime"] = lifetime;
		let args["cookie_secure"] = secure ? 1 : 0;

		if (session_status() !== PHP_SESSION_ACTIVE) {
			session_start(args);
		}
	}

	public static function write(args, data = null)
	{
		var name, command;

		let command = new Command();

		if (is_array(args)) {
			if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
				if (command->isVariable(args[0])) {
					let name = trim(args[0], "\"");
				} else {
					let name = args[0];
				}
			} else {
				throw new Exception("Invalid SESSWRITE");
			}

			if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
				if (command->isVariable(args[1])) {
					let data = trim(args[1], "\"");
				} else {
					let data = args[1];
				}
				
			} else {
				throw new Exception("Invalid SESSWRITE");
			}
		} else {
			let name = args;
		}

		return "<?php $_SESSION[" . name . "] = " . data . "; ?>";
	}
}
