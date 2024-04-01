/**
 * Text parser
 *
 * @package     KytschBASIC\Parsers\Core\Text
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
namespace KytschBASIC\Parsers\Core\Text;

use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Maths;

class Text extends Command
{
	public function commands(args)
	{
		var command = "", splits = [];

		let splits = explode(" ", trim(args));
		let command = splits[0];
		array_shift(splits);
		let splits = implode(" ", splits);

		if (command == "ASC") {
			return ord(trim(splits, "\""));
		} elseif (command == "CENTRE") {
			return this->processCentre(splits);
		}

		return args;
	}

	public function parse(string command, string args)
	{
		let args = this->commands(args);

		if (command == "PRINT") {
			return this->processPrint(args);
		} elseif (command == "SWRITE CLOSE") {
			return "</p>";
		} elseif (command == "SWRITE") {
			return this->processSWrite(args);
		} elseif (command == "LINE BREAK") {
			return "<br/>";
		}

		return null;
	}

	private function processCentre(args)
	{
		var value="";

		let args = this->args(args);
		let value = this->setArg(args[0]);

		if (isset(args[1])) {
			let value = substr(
				value,
				(strlen(value) / 2) - 1,
				intval(args[1])
			);
		}

		return "\"" . value . "\"";
	}

	private function processPrint(args)
	{
		var params="", value="";

		let args = this->args(args);
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

	private function processSWrite(args)
	{
		var params="";

		let args = this->args(args);
		
		if (isset(args[0])) {
			let params .= " class='" . this->setArg(args[0]) . "'";
		}

		if (isset(args[1])) {
			let params .= " id='" . this->setArg(args[1]) . "'";
		} else {
			let params .= " id='" . this->genID("kb-span") . "'";
		}
		
		return "<?= \"<p" . params . ">\"; ?>";
	}
}
