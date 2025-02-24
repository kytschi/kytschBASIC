/**
 * Navigation parser
 *
 * @package     KytschBASIC\Parsers\Core\Navigation
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2024 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.1
 *
 * Copyright 2024 Mike Welsh
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
	public function parse(string command, string args)
	{
		if (command == "LINK CLOSE") {
			return "</a>";
		} elseif (command == "LINK") {
			return this->processLink(args);
		} elseif (command == "MENU CLOSE") {
			return "</nav>";
		} elseif (command == "MENU") {
			return this->processNav(args);
		}

		return null;
	}

	private function processLink(string line)
	{
		var args, params="";

		let args = this->args(line);
		
		if (isset(args[0]) && !empty(args[0])) {
			let params .= " href='" . this->setArg(args[0]) . "'";
		}

		if (isset(args[1]) && !empty(args[1])) {
			let params .= " title='" . this->setArg(args[1]) . "'";
		}

		if (isset(args[2]) && !empty(args[2])) {
			let params .= " class='" . this->setArg(args[2]) . "'";
		}

		if (isset(args[3]) && !empty(args[3])) {
			let params .= " target='" . this->setArg(args[3]) . "'";
		}

		if (isset(args[4]) && !empty(args[4])) {
			let params .= " id='" . this->setArg(args[4]) . "'";
		} else {
			let params .= " id='" . this->genID("kb-a") . "'";
		}
		
		return "<?= \"<a" . params . ">\"; ?>";
	}

	private function processNav(string line)
	{
		var args, params="";

		let args = this->args(line);
		
		if (isset(args[0]) && !empty(args[0])) {
			let params .= " class='" . this->setArg(args[0]) . "'";
		}

		if (isset(args[1]) && !empty(args[1])) {
			let params .= " id='" . this->setArg(args[1]) . "'";
		} else {
			let params .= " id='" . this->genID("kb-span") . "'";
		}
		
		return "<?= \"<nav" . params . ">\"; ?>";
	}
}
