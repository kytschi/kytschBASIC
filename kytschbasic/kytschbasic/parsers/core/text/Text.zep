/**
 * Text parser
 *
 * @package     KytschBASIC\Parsers\Core\Text
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
namespace KytschBASIC\Parsers\Core\Text;

use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Maths;

class Text extends Command
{
	public function parse(string command, string args)
	{
		if (command == "PRINT") {
			return this->processPrint(args);
		} elseif (command == "SWRITE CLOSE") {
			return "</p>";
		} elseif (command == "SWRITE") {
			return this->processSWrite(command);
		}

		return null;
	}

	private function processPrint(string line)
	{
		var args, params="", value="";

		let args = this->args(line);
		let value = this->setArg(args[0], false);

		if (isset(args[1])) {
			let params .= " class='" . this->setArg(args[1]) . "'";
		}

		if (isset(args[2])) {
			let params .= " id='" . this->setArg(args[2]) . "'";
		} else {
			let params .= " id='" . this->genID("kb-span") . "'";
		}
		
		return "<?= \"<span" . params . ">\" . (" . value . ") . \"</span>\";?>";
	}

	private function processSWrite(string line)
	{
		var args, params="";

		let args = explode("\",", line);
		if (isset(args[0])) {
			let params .= " class=\"" . trim(args[0], "\"") . "\"";	
		}

		if (isset(args[1])) {
			let params .= " id=\"" . trim(args[1], "\"") . "\"";	
		} else {
			let params .= " id=\"" . this->genID("kb-p") . "\"";
		}
		
		return "<p" . params . ">";
	}
}
