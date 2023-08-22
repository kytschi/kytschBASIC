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
	protected id = "";
	protected _class = "";

	protected link = "";
	protected target = "";
	protected title = "";

	public function parse(
		string line,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (this->match(line, "LINK CLOSE")) {
			return "</a>";
		} elseif (this->match(line, "LINK")) {
			return this->processLink(line, event_manager, globals);
		} elseif (this->match(line, "MENU CLOSE")) {
			return "</nav>";
		} elseif (this->match(line, "MENU")) {
			return this->processNav(line, event_manager, globals);
		}

		return null;
	}

	private function processLink(
		string line,
		event_manager,
		array globals
	) {
		let this->id = this->genID("kb-a");

		var args, params="";
		let args = this->parseArgs("LINK", line);

		if (isset(args[0])) {
			if (!this->isVar(args[0])) {
				let params = params . " href=\"" . this->cleanArg(args[0]) . "\"";
			} else {
				let params = params . " href=\"<?= " . this->parseVar(args[0]) . ";?>\"";
			}
		}

		if (isset(args[1])) {
			if (!this->isVar(args[1])) {
				let params = params . " title=\"" . this->cleanArg(args[1]) . "\"";
			} else {
				let params = params . " title=\"<?= " . this->parseVar(args[1]) . ";?>\"";
			}
		}

		if (isset(args[2])) {
			if (!this->isVar(args[2])) {
				let params = params . " class=\"" . this->cleanArg(args[2]) . "\"";
			} else {
				let params = params . " class=\"<?= " . this->parseVar(args[2]) . ";?>\"";
			}
		}

		if (isset(args[3])) {
			if (!this->isVar(args[3])) {
				let params = params . " target=\"" . this->cleanArg(args[3]) . "\"";
			} else {
				let params = params . " target=\"<?= " . this->parseVar(args[3]) . ";?>\"";
			}
		}

		if (isset(args[4])) {
			if (!this->isVar(args[4])) {
				let params = params . " id=\"" . this->cleanArg(args[4]) . "\"";
			} else {
				let params = params . " id=\"<?= " . this->parseVar(args[4]) . ";?>\"";
			}
		} else {
			let params = params . " id=\"" . this->id . "\"";
		}

		let params = params . this->leftOverArgs(5, args);

		return "<a" . params . ">";
	}

	private function processNav(
		string line,
		event_manager,
		array globals
	) {
		let this->id = this->genID("kb-nav");

		var args, arg, params="";
		let args = this->parseArgs("MENU", line);

		if (isset(args[0])) {
			let arg = this->cleanArg(args[0]);
			if (!empty(arg)) {
				let this->_class = arg;
				let params = params . " class=\"" . this->_class . "\"";
			}
		}

		if (isset(args[1])) {
			let arg = this->cleanArg(args[1]);
			if (!empty(arg)) {
				let this->id = arg;
			}
		}

		let params = params . " id=\"" . this->id . "\"";

		let params = params . this->leftOverArgs(2, args);

		return "<nav" . params . ">";
	}
}
