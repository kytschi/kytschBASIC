/**
 * Input parser
 *
 * @package     KytschBASIC\Parsers\Core\Input\Form
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
namespace KytschBASIC\Parsers\Core\Input;

use KytschBASIC\Parsers\Core\Command;

class Form extends Command
{
	public function parse(string command, string args)
	{
		if (command == "FORM CLOSE") {
			return "</form>";
		} elseif (command == "FORM") {
			return this->processForm(args);
		} elseif (command == "TEXTINPUT") {
			return this->processFormInput(args);
		}

		return null;
	}

	private function processForm(string line)
	{
		var args, params="";

		let args = this->args(line);
		
		if (isset(args[0]) && !empty(args[0])) {
			let params .= " id='" . this->setArg(args[0]) . "'";
		} else {
			let params .= " id='" . this->genID("kb-form") . "'";
		}

		var method = "GET";
		if (isset(args[1]) && !empty(args[1])) {
			if (in_array(strtoupper(args[1]), ["GET", "POST"])) {
				let method = strtoupper(args[1]);
			}
		}
		let params .= " method='" . method . "'";

		if (isset(args[2]) && !empty(args[2])) {
			let params .= " action='" . this->setArg(args[2]) . "'";
		}

		if (isset(args[3]) && !empty(args[3])) {
			let params .= " class='" . this->setArg(args[3]) . "'";
		}
		
		return "<?= \"<form" . params . ">\"; ?>";
	}

	private function processFormInput(string line, string type = "text")
	{
		var args, params="";

		let args = this->args(line);
		
		if (isset(args[0]) && !empty(args[0])) {
			let params .= " name='" . this->setArg(args[0]) . "'";
		} else {
			let params .= " name='" . this->genID("kb-form-input") . "'";
		}

		if (isset(args[1]) && !empty(args[1])) {
			let params .= " class='" . this->setArg(args[1]) . "'";
		}

		if (isset(args[2]) && !empty(args[2])) {
			let params .= " placeholder='" . this->setArg(args[2]) . "'";
		}

		if (isset(args[3]) && !empty(args[3])) {
			let params .= " id='" . this->setArg(args[3]) . "'";
		} else {
			let params .= " id='" . this->genID("kb-form-input") . "'";
		}

		if (isset(args[4]) && !empty(args[4])) {
			let params .= " required='required'";
		}
		
		return "<?= \"<input type='" . type . "'" . params . ">\"; ?>";
	}
}
