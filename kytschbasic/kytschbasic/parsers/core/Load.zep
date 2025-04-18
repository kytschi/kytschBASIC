/**
 * Load parser
 *
 * @package     KytschBASIC\Parsers\Core\Load
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
namespace KytschBASIC\Parsers\Core;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Libs\Arcade\Arcade;
use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Parser;

class Load extends Command
{
	public function parse(string line, string command, array args)
	{
		switch (command) {
			case "LOAD":
				return this->parseLoad(args);
			case "INCLUDE":
				return this->parseInclude(args);
			default:
				return null;
		}
	}

	private function parseInclude(array args)
	{
		if(empty(args[0])) {
			throw new Exception("Invalid INCLUDE");
		}

		switch (strtolower(args[0])) {
			case "arcade":
				return (new Arcade())->build();
			default:
				throw new Exception("Invalid library to include");
		}
	}

	private function parseLoad(array args)
	{
		var ext;

		if(empty(args[0])) {
			throw new Exception("Invalid INCLUDE");
		}

		let ext = pathinfo(args[0], PATHINFO_EXTENSION);

		switch (ext) {
			case "js":
				return "<script src=" . this->outputArg(args[0]) . "></script>";
			default:
				return (new Parser())->parse(trim(args[0], "\"") . ".kb", false);
		}
	}
}
