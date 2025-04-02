/**
 * Select parser
 *
 * @package     KytschBASIC\Parsers\Core\Conditional\Select
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.2
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
namespace KytschBASIC\Parsers\Core\Conditional;

use KytschBASIC\Parsers\Core\Command;

class Select extends Command
{
	private open_case = false;

	public function parse(string line, string command, array args)
	{
		/*if (command == "SELECT") {
			return "<?php switch (" .
				this->clean(args, this->isVariable(args)) .
			") { ?>";
		}*/
		return null;
	}
}