/**
 * Navigation parser
 *
 * @package     KytschBASIC\Parsers\Core\Navigation
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

use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Command;

class Navigation extends Command
{
	protected static id = "";
	protected static _class = "";

	protected static link = "";
	protected static target = "";
	protected static title = "";

	public static function parse(
		string line,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (self::match(line, "LINK CLOSE")) {
			return "</a>";
		} elseif (self::match(line, "LINK")) {
			return self::processLink(line, event_manager, globals);
		} elseif (self::match(line, "MENU CLOSE")) {
			return "</nav>";
		} elseif (self::match(line, "MENU")) {
			return self::processNav(line, event_manager, globals);
		}

		return null;
	}

	private static function processLink(
		string line,
		event_manager,
		array globals
	) {
		let self::id = self::genID("kb-a");

		var args, arg, params="";
		let args = self::parseArgs("LINK", line);

		if (isset(args[0])) {
			let arg = self::cleanArg(args[0]);
			if (!empty(arg)) {
				let self::link = arg;
				let params = params . " href=\"" . self::link . "\"";
			}
		}

		if (isset(args[1])) {
			let arg = self::cleanArg(args[1]);
			if (!empty(arg)) {
				let self::title = arg;
				let params = params . " title=\"" . self::title . "\"";
			}
		}

		if (isset(args[2])) {
			let arg = self::cleanArg(args[2]);
			if (!empty(arg)) {
				let self::_class = arg;
				let params = params . " class=\"" . self::_class . "\"";
			}
		}

		if (isset(args[3])) {
			let arg = self::cleanArg(args[3]);
			if (!empty(arg)) {
				let self::target = arg;
				let params = params . " target=\"" . self::target . "\"";
			}
		}

		if (isset(args[4])) {
			let arg = self::cleanArg(args[4]);
			if (!empty(arg)) {
				let self::id = arg;
			}
		}

		let params = params . " id=\"" . self::id . "\"";

		let params = params . self::leftOverArgs(5, args);

		return "<a" . params . ">";
	}

	private static function processNav(
		string line,
		event_manager,
		array globals
	) {
		let self::id = self::genID("kb-nav");

		var args, arg, params="";
		let args = self::parseArgs("MENU", line);

		if (isset(args[0])) {
			let arg = self::cleanArg(args[0]);
			if (!empty(arg)) {
				let self::_class = arg;
				let params = params . " class=\"" . self::_class . "\"";
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

		return "<nav" . params . ">";
	}
}
