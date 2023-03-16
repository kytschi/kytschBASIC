/**
 * Form parser
 *
 * @package     KytschBASIC\Parsers\Core\Layout\Form
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
namespace KytschBASIC\Parsers\Core\Layout;

use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Command;

class Form extends Command
{
	protected static id = "";
	protected static _class = "";

	public static function parse(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (self::match(command, "FORM CLOSE")) {
			return self::output("</form>");
		} elseif (self::match(command, "FORM INPUT")) {
			return self::processInput(command, event_manager, globals);
		} elseif (self::match(command, "FORM SUBMIT")) {
			return self::processButton(command, event_manager, globals, "submit");
		} elseif (substr(command, 0, 4) == "FORM") {
			return self::processForm(command, event_manager, globals);
		}

		return null;
	}

	private static function processButton(
		string command,
		event_manager,
		array globals,
		string type = "button"
	) {
		let self::id = self::genID("kb-button");

		var args, arg, params="", label="button";
		let args = Args::parseShort(strtoupper("form submit"), command);

		let params .= " type=\"" . type . "\"";

		if (isset(args[0])) {
			let arg = Args::clean(args[0]);
			if (!empty(arg)) {
				let params .= " name=\"" . arg . "\"";
			}
		}

		if (isset(args[1])) {
			let arg = Args::clean(args[1]);
			if (!empty(arg)) {
				let label = arg;
			}
		}

		if (isset(args[2])) {
			let arg = Args::clean(args[2]);
			if (!empty(arg)) {
				let self::_class = arg;
				let params .= " class=\"" . self::_class . "\"";
			}
		}

		if (isset(args[3])) {
			let arg = Args::clean(args[3]);
			if (!empty(arg)) {
				let self::id = arg;
			}
		}

		let params .= " id=\"" . self::id . "\"";

		let params .= Args::leftOver(4, args);

		return self::output("<button " . params . ">" . label . "</button>");
	}

	private static function processInput(
		string command,
		event_manager,
		array globals
	) {
		let self::id = self::genID("kb-input");

		var args, arg, params="";
		let args = Args::parseShort(strtoupper("form input"), command);

		if (isset(args[0])) {
			let arg = Args::clean(args[0]);
			if (!empty(arg)) {
				let params .= " name=\"" . arg . "\"";
			}
		}

		if (isset(args[1])) {
			let arg = Args::clean(args[1]);
			if (!empty(arg)) {
				let self::_class = arg;
				let params .= " class=\"" . self::_class . "\"";
			}
		}

		if (isset(args[2])) {
			let arg = Args::clean(args[2]);
			if (!empty(arg)) {
				let params .= " placeholder=\"" . arg . "\"";
			}
		}

		if (isset(args[3])) {
			let arg = Args::clean(args[3]);
			if (!empty(arg)) {
				let self::id = arg;
			}
		}

		let params = params . " id=\"" . self::id . "\"";

		let params = params . Args::leftOver(4, args);

		return self::output("<input " . params . ">");
	}

	private static function processForm(
		string command,
		event_manager,
		array globals
	) {
		let self::id = self::genID("kb-form");

		var args, arg, params="";
		let args = Args::parseShort(strtoupper("form"), command);

		if (isset(args[0])) {
			let arg = Args::clean(args[0]);
			if (!empty(arg)) {
				let self::id = arg;
			}
		}

		if (isset(args[1])) {
			let arg = Args::clean(args[1]);
			if (!empty(arg)) {
				if (!in_array(["get", "post"], strtolower(arg))) {
					let params .= " method=\"" . strtolower(arg) . "\"";
				} else {
					let params .= " method=\"get\"";
				}
			} else {
				let params .= " method=\"get\"";
			}
		}

		if (isset(args[2])) {
			let arg = Args::clean(args[2]);
			if (!empty(arg)) {
				let self::_class = arg;
				let params .= " class=\"" . self::_class . "\"";
			}
		}

		let params .= " id=\"" . self::id . "\"";

		let params .= Args::leftOver(3, args);

		return self::output("<form " . params . ">");
	}
}
