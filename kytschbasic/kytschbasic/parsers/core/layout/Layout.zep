/**
 * Layout parser
 *
 * @package     KytschBASIC\Parsers\Core\Layout\Layout
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2024 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.2
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
namespace KytschBASIC\Parsers\Core\Layout;

use KytschBASIC\Parsers\Core\Command;

class Layout extends Command
{
	public function parse(string command, string args)
	{
		if (command == "DIV CLOSE") {
			return "</div>";
		} elseif (command == "DIV") {
			return this->processTag("div", args);
		} elseif (command == "BODY CLOSE") {
			return "</body>";
		} elseif (command == "BODY") {
			return this->processTag("body", args);
		} elseif (command == "FOOTER CLOSE") {
			return "</footer>";
		} elseif (command == "FOOTER") {
			return this->processTag("footer", args);
		} elseif (command == "HEADER CLOSE") {
			return "</header>";
		} elseif (command == "HEADER") {
			return this->processTag("header", args);
		} elseif (command == "MAIN CLOSE") {
			return "</main>";
		} elseif (command == "MAIN") {
			return this->processTag("main", args);
		} elseif (command == "END") {
			return "</html>";
		} 

		return null;
	}

	private function processTag(string tag, string line)
	{
		var args, params="";

		let args = this->args(line);
		
		if (isset(args[0]) && !empty(args[0])) {
			let params .= " class='" . this->setArg(args[0]) . "'";
		}

		if (isset(args[1]) && !empty(args[1])) {
			let params .= " id='" . this->setArg(args[1]) . "'";
		} else {
			let params .= " id='" . this->genID("kb-" . tag) . "'";
		}
		
		return "<?= \"<" . tag . params . ">\"; ?>";
	}
}
