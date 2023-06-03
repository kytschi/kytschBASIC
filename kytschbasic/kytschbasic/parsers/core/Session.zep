/**
 * Load parser
 *
 * @package     KytschBASIC\Parsers\Core\Session
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

use KytschBASIC\Parsers\Core\Command;

class Session extends Command
{
	public function addLastCreate(shape)
	{
		this->write("LAST_CREATE", shape);
	}

	public static function clear(string name)
	{
		if (array_key_exists(name, _SESSION)) {
			unset _SESSION[name];
		}
	}

	public function getLastCreate()
	{
		return this->read("LAST_CREATE");
	}

	public function parse(
		string command,		
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (this->match(command, "SESSION GET ")) {
			return trim(str_replace("SESSION GET ", "", command), "\"");
		}

		return null;
	}

	public function read(string name)
	{
		var data = null;

		if (array_key_exists(name, _SESSION)) {
			let data = _SESSION[name];
		}

		return data;
	}

	public function start(config)
	{
		if(headers_sent() && session_id()) {
			return;
		}

		var args, name, lifetime;

		let name = "kytschBASIC";
		let lifetime = 86400;

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
			}
		}

		let args = [];
		let args["name"] = name;
		let args["cookie_lifetime"] = lifetime;

		if (session_status() === 1) {
			session_start(args);
		}
	}

	public function write(string name, data)
	{
		let _SESSION[name] = data;
	}
}
