/**
 * Heading parser
 *
 * @package     KytschBASIC\Parsers\Core\Text\Heading
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

use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Command;

class Heading extends Command
{
	public function parse(string command, string args)
	{
		if (command == "HEADING CLOSE") {
			return this->processHeading(args, true);
		} elseif (command == "HEADING") {
			return this->processHeading(args);
		}

		return null;
	}

	private function processHeading(string line, bool close = false)
	{
		var args, params="", size = 1;

		let args = this->args(line);

		if (isset(args[0])) {
			let size = this->setArg(args[0], false);
		}
		if (close) {
			return "<?= \"</h" . size . ">\"; ?>";
		}

		if (isset(args[1])) {
			let params .= " class='" . this->setArg(args[1]) . "'";
		}

		if (isset(args[2])) {
			let params .= " id='" . this->setArg(args[2]) . "'";
		} else {
			let params .= " id='" . this->genID("kb-heading") . "'";
		}

		return "<?= \"<h" . size . params . ">\"; ?>";
	}
}
