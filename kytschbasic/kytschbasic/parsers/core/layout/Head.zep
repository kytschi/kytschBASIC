/**
 * Head parser
 *
 * @package     KytschBASIC\Parsers\Core\Layout\Head
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
namespace KytschBASIC\Parsers\Core\Layout;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Libs\Arcade\Arcade;
use KytschBASIC\Parsers\Core\Command;

class Head extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch(command) {
			case "AUTHOR":
				return this->processMeta("author", command, args);
			case "CHARSET":
				return this->processCharset(args);
			case "DESCRIPTION":
				return this->processMeta("description", command, args);
			case "END HEAD":
				return "</head>";
			case "FAVICON":
				return this->processFavicon(args);
			case "HEAD":
				return "<head>" . (new Arcade())->build();
			case "KEYWORDS":
				return this->processMeta("keywords", command, args);
			case "LANG":
				return this->processLang(args);
			case "NAME":
				return this->processName(args);
			case "SCRIPT":
				return this->processScript(args);
			case "VIEWPORT":
				return this->processMeta("viewport", command, args);
			default:
				return null;
		}
	}

	private function processCharset(array args)
	{
		if (empty(args[0])) {
			throw new Exception("Invalid CHARSET");
		}
		
		return "<?= \"<meta charset=" . this->outputArg(args[0], false) . ">\"; ?>";
	}

	private function processFavicon(array args)
	{
		var output = "<?= \"<link rel=";

		if (empty(args[0])) {
			throw new Exception("Invalid FAVICON");
		}

		let output .= this->outputArg("icon", false);

		let output .= " href=" . this->outputArg(args[0], false);
		
		if (isset(args[1]) && !empty(args[1])) {
			let output .= " sizes=" . this->outputArg(args[1], false);
		}

		return output . ">\"; ?>";
	}

	private function processMeta(string type, string command, array args)
	{
		if (empty(args[0])) {
			throw new Exception("Invalid " . command);
		}
		
		return "<?= \"<meta name=" . this->outputArg(type, false) . " content=" . this->outputArg(args[0], false) . ">\"; ?>";
	}

	private function processLang(array args)
	{
		if (empty(args[0])) {
			throw new Exception("Invalid LANG");
		}
		
		return "<?= \"<html lang=" . this->outputArg(args[0], false) . ">\"; ?>";
	}

	private function processName(array args)
	{
		if (empty(args[0])) {
			throw new Exception("Invalid NAME");
		}
		
		return "<?= \"<title>\" . " . args[0] . " . \"</title>\"; ?>";
	}

	private function processScript(array args)
	{
		var config, output = "<?= \"<script", href, type = "text/javascript";
		let config = constant("CONFIG");

		if (empty(args[0])) {
			throw new Exception("Invalid SCRIPT");
		}

		if (isset(args[1]) && !empty(args[1])) {
			let type = args[1];
		}

		let output .= " type=" . this->outputArg(type, false);

		let href = args[0] . " . '.js'";
		
		if (!empty(config["cache"])) {
			if (empty(config["cache"]->enabled)) {
				let href .= "?no-cache=" . microtime();
			}
		}

		let output .= " src=" . this->outputArg(href, false);

		return output . "></script>\"; ?>";
	}
}
