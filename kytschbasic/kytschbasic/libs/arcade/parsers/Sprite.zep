/**
 * SPRITE parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Sprite
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
namespace KytschBASIC\Libs\Arcade\Parsers;

use KytschBASIC\Parsers\Core\Command;

class Sprite extends Command
{
	/*public function parse(string line, string command, array args)
	{
		if (command == "SPRITE") {
			return this->parseSprite(args);
		} elseif (command == "END SPRITE") {
			return "</div>";
		}
	}

	public function parseSprite(args)
	{
		var params = "", cleaned;
		let args = this->args(args);

		if (isset(args[0])) {
			let params .= " id=" . this->outputArg(args[0]);
		} else {
			let params .= " id=" . this->outputArg(this->genID("kb-window"));
		}

		if (isset(args[1])) {
			let params .= " class=" . this->outputArg(args[1]);
		}

		if (isset(args[2])) {
			if (substr(args[2], 0, 1) == "\"") {
				let cleaned = trim(args[2], "\"");
			} else {
				let cleaned = this->outputArg(args[2], false);
			}

			let params .= " onclick='javascript:" . cleaned . "(event)'";
		}
		
		return "<?= \"<div" . params . ">\"; ?>";
	}*/
}
