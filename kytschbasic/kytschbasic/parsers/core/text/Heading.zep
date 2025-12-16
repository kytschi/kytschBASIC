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
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch(command) {
			case "HEADING":
				return this->processHeading(args);
			default:
				if (strpos(command, "END HEADING") !== false) {
					return this->processHeading(args, command);
				} else {					
					return null;
				}
		}
	}

	private function processHeading(args, string close = "")
	{
		var params="", size = 1;

		if (close) {
			let close = ltrim(close, "END HEADING ");
			let args = this->args(close);
		}

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let size = this->outputArg(args[0], false, false);
		}

		if (close) {
			return "<?= \"</h\" . intval(" . size . ") . \">\"; ?>";
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let params .= " class=" . this->outputArg(args[1], false);
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let params .= " id=" . this->outputArg(args[2], false);
		} else {
			let params .= " id=" . this->outputArg(this->genID("kb-heading"), false);
		}

		return "<?= \"<h\" . intval(" . size . ") . \"" . params . ">\"; ?>";
	}
}
