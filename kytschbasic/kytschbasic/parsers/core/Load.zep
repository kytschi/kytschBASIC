/**
 * Load parser
 *
 * @package     KytschBASIC\Parsers\Core\Load
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2022 Mike Welsh
 * @link 		https://kytschbasic.org
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

use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Parser;

class Load extends Command
{
	public function parse(string command, string args)
	{
		if (command == "LOAD") {
			var ext;

			if (substr(args, 0, 1) != "\"") {
				let args = this->clean(args);
			} else {
				let args = this->constants(args) . "\"";
			}

			let ext = pathinfo(args, PATHINFO_EXTENSION);
			switch (ext) {
				case "js":
					let ext = "<script src=" . args . "></script>";
				default:
					let ext = (new Parser())->parse(trim(args, "\"") . ".kb");
					break;
			}

			return ext;
		}

		return null;
	}
}
