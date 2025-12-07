/**
 * Navigation parser
 *
 * @package     KytschBASIC\Parsers\Core\Navigation
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

use KytschBASIC\Parsers\Core\Command;

class Navigation extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch(command) {
			case "END LINK":
				return "</a>";
			case "END MENU":
				return "</nav>";
			case "GOTO":
				return this->processGoto(args, in_javascript);
			case "LINK":
				return this->processLink(args);
			case "MENU":
				return this->processNav(args);
			default:
				return null;
		}
	}

	private function processGoto(array args, bool in_javascript = false)
	{
		var output = "", splits, str;

		if (strpos("http:", args[0]) !== false || strpos("ftp:", args[0]) !== false) {
			return "<?php header(\"Location: \" . " . args[0] . ");die(); ?>";
		} else {
			if (strpos(args[0], "[") !== false) {
				let output = substr_replace(
					substr_replace(args[0], "(", strpos(args[0], "["), 1),
					")",
					strlen(args[0]) - 1,
					1
				);

				let output = rtrim(output, ";");

				if (in_javascript) {
					let splits = preg_split("/\"[^\"]*\"(*SKIP)(*FAIL)|\K\(/", output);
					if (splits) {
						let output = splits[0] . "(event";
						array_shift(splits);
						for (str in splits) {
							if (str != ")") {
								let output .= ", " . str;
							} else {
								let output .= str;
							}
						}
					}
					return output . ";";
				} else {
					return "<?php " . output . "; ?>";
				}
			} else {
				let output = rtrim(args[0], ";");
				if (in_javascript) {
					return output . "(event);";
				} else {
					return "<?php " . output . "(); ?>";
				}
			}
		}
	}

	private function processLink(array args)
	{
		var output = "<?= \"<a";
				
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= " href=" . this->outputArg(args[0]);
		}

		if (isset(args[1]) && !empty(args[1])) {
			let output .= " title=" . this->outputArg(args[1]);
		}

		if (isset(args[2]) && !empty(args[2])) {
			let output .= " class=" . this->outputArg(args[2]);
		}

		if (isset(args[3]) && !empty(args[3])) {
			let output .= " target=" . this->outputArg(args[3]);
		}

		if (isset(args[4]) && !empty(args[4])) {
			let output .= " id=" . this->outputArg(args[4]);
		} else {
			let output .= " id=" . this->outputArg(this->genID("kb-a"), true);
		}
		
		return  output . ">\"; ?>";
	}

	private function processNav(array args)
	{
		var output = "<?= \"<nav";
		
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= " class=" . this->outputArg(args[0]);
		}

		if (isset(args[1]) && !empty(args[1])) {
			let output .= " id=" . this->outputArg(args[1]);
		} else {
			let output .= " id=" . this->outputArg(this->genID("kb-span"), true);
		}
		
		return  output . ">\"; ?>";
	}
}
