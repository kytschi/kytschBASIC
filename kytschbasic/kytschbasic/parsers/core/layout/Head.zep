/**
 * Head parser
 *
 * @package     KytschBASIC\Parsers\Core\Layout\Head
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2024 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.1
 *
 * Copyright 2023 Mike Welsh
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

use KytschBASIC\Parsers\Core\Command;

class Head extends Command
{
	public function parse(string command, string args)
	{
		if (command == "END HEAD") {
			return "</head>";
		} elseif (command == "HEAD" && command != "HEADI") {
			return "<head>";
		} elseif (command == "PALETTE") {
			return this->processPalette(args);
		} elseif (command == "NAME") {
			return this->processName(args);
		} elseif (command == "LANG") {
			return this->processLang(args);
		} elseif (command == "CHARSET") {
			return this->processCharset(args);
		} elseif (command == "DESCRIPTION") {
			return this->processMeta("description", args);
		} elseif (command == "KEYWORDS") {
			return this->processMeta("keywords", args);
		} elseif (command == "AUTHOR") {
			return this->processMeta("author", args);
		} elseif (command == "VIEWPORT") {
			return this->processMeta("viewport", args);
		}  elseif (command == "FAVICON") {
			return this->processFavicon(args);
		}

		return null;
	}

	private function processCharset(string line)
	{
		var args;
		let args = explode("\",", line);
		if (isset(args[0]) && !empty(args[0])) {
			return "<meta charset=\"" . this->setArg(args[0]) . "\">";
		}
		
		return "";
	}

	private function processFavicon(string line)
	{
		var args;
		let args = explode("\",", line);
		let line = "";

		if (isset(args[0]) && !empty(args[0])) {
			let line = "<link rel=\"icon\" href=\"" . this->setArg(args[0]) . "\"";
		}
		
		if (isset(args[1])) {
			let line .= " sizes=\"" . this->setArg(args[1]) . "\"";
		}

		return line . ">";
	}

	private function processMeta(string type, string line)
	{
		var args;
		let args = explode("\",", line);
		if (isset(args[0]) && !empty(args[0])) {
			return "<meta name=\"" . type . "\" content=\"" . this->setArg(args[0]) . "\">";
		}
		
		return "";
	}

	private function processLang(string line)
	{
		var args;
		let args = explode("\",", line);
		if (isset(args[0]) && !empty(args[0])) {
			return "<html lang=\"" . this->setArg(args[0]) . "\">";
		}

		return "";
	}

	private function processName(string line)
	{
		var args;
		let args = explode("\",", line);
		if (isset(args[0]) && !empty(args[0])) {
			return "<title>" . this->setArg(args[0]) . "</title>";
		}

		return "";
	}

	private function processPalette(string line)
	{
		var args, config;
		let config = constant("CONFIG");

		let args = explode("\",", line);
		
		if (isset(args[0]) && !empty(args[0])) {
			let args[0] = "<link rel=\"stylesheet\" type=\"text/css\" href=\"/" . this->setArg(args[0]) . "/css/palette.css";
						
			if (!empty(config["cache"])) {
				if (empty(config["cache"]->enabled)) {
					let args[0] = args[0] . "?no-cache=" . microtime();
				}
			}

			return args[0] . "\">";				
		}

		return "";
	}
}
