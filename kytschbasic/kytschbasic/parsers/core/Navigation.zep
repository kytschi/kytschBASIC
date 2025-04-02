/**
 * Navigation parser
 *
 * @package     KytschBASIC\Parsers\Core\Navigation
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
namespace KytschBASIC\Parsers\Core;

use KytschBASIC\Parsers\Core\Command;

class Navigation extends Command
{
	/*public function parse(string line, string command, array args)
	{
		if (command == "END LINK") {
			return "</a>";
		} elseif (command == "LINK") {
			return this->processLink(args);
		} elseif (command == "END MENU") {
			return "</nav>";
		} elseif (command == "MENU") {
			return this->processNav(args);
		} elseif (command == "GOTO") {
			return "<?php header(\"Location: " . this->setArg(args) . "\"); ?>";
		} 

		return null;
	}

	private function processLink(string line)
	{
		var args, params="";

		let args = this->args(line);
				
		if (isset(args[0]) && !empty(args[0])) {
			let params .= " href=" . this->outputArg(args[0]);
		}

		if (isset(args[1]) && !empty(args[1])) {
			let params .= " title=" . this->outputArg(args[1]);
		}

		if (isset(args[2]) && !empty(args[2])) {
			let params .= " class=" . this->outputArg(args[2]);
		}

		if (isset(args[3]) && !empty(args[3])) {
			let params .= " target=" . this->outputArg(args[3]);
		}

		if (isset(args[4]) && !empty(args[4])) {
			let params .= " id=" . this->outputArg(args[4]);
		} else {
			let params .= " id=" . this->outputArg(this->genID("kb-a"));
		}
		
		return "<?= \"<a" . params . ">\"; ?>";
	}

	private function processNav(string line)
	{
		var args, params="";

		let args = this->args(line);
		
		if (isset(args[0]) && !empty(args[0])) {
			let params .= " class=" . this->outputArg(args[0]);
		}

		if (isset(args[1]) && !empty(args[1])) {
			let params .= " id=" . this->outputArg(args[1]);
		} else {
			let params .= " id=" . this->outputArg(this->genID("kb-span"));
		}
		
		return "<?= \"<nav" . params . ">\"; ?>";
	}*/
}
