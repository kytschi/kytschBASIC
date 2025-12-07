/**
 * Display parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Screen\Display
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
namespace KytschBASIC\Libs\Arcade\Parsers\Screen;

use KytschBASIC\Helpers\Cookie;

class Display
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch (command) {
			case "DISPHEIGHT":
				return this->parseDisplay(1);
			case "DISPWIDTH":
				return this->parseDisplay(0);
			default:
				return null;
		}
	}

	private function parseDisplay(int index)
	{
		var return_value = 10, display;

		let display = (new Cookie())->get("display");
		
		if (display) {
			if (isset(display[index])) {
				let return_value = display[index];
			}
		}

		return return_value;
	}
}
