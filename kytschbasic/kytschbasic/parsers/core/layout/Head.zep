/**
 * Head parser
 *
 * @package     KytschBASIC\Parsers\Core\Layout\Head
 * @author 		Mike Welsh
 * @copyright   2023 Mike Welsh
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

use KytschBASIC\Parsers\Core\Args;

use KytschBASIC\Parsers\Core\Command;

class Head extends Command
{
	public function parse(
		string line,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		var args, controller;
		let controller = new Args();

		if (this->match(line, "HEAD CLOSE")) {
			return "</head>";
		} elseif (this->match(line, "HEAD") && !this->match(line, "HEADI")) {
			return "<head>";
		} elseif (this->match(line, "PALETTE")) {
			let args = controller->parseShort("PALETTE", line);
			if (isset(args[0])) {
				var str = "";
				let str = "<link rel=\"stylesheet\" type=\"text/css\" href=\"/" . this->cleanArg(args[0]) . "/css/palette.css";
				
				if (!empty(config["cache"])) {
					if (empty(config["cache"]->enabled)) {
						let str = str . "?no-cache=" . microtime();
					}
				}

				return str . "\">";				
			}

			return "";
		} elseif (this->match(line, "NAME")) {
			let args = controller->parseShort("NAME", line);
			if (isset(args[0])) {
				return "<title>" . this->cleanArg(args[0]) . "</title>";
			}

			return "";
		} elseif (this->match(line, "LANG")) {
			let args = controller->parseShort("LANG", line);
			if (isset(args[0])) {
				return "<html lang=\"" . this->cleanArg(args[0]) . "\">";
			}

			return "";
		} elseif (this->match(line, "CHARSET")) {
			let args = controller->parseShort("CHARSET", line);
			if (isset(args[0])) {
				return "<meta charset=\"" . this->cleanArg(args[0]) . "\">";
			}

			return "";
		} elseif (this->match(line, "DESCRIPTION")) {
			let args = controller->parseShort("DESCRIPTION", line);
			if (isset(args[0])) {
				return "<meta name=\"description\" content=\"" . this->cleanArg(args[0]) . "\">";
			}

			return "";
		} elseif (this->match(line, "KEYWORDS")) {
			let args = controller->parseShort("KEYWORDS", line);
			if (isset(args[0])) {
				return "<meta name=\"keywords\" content=\"" . this->cleanArg(args[0]) . "\">";
			}

			return "";
		} elseif (this->match(line, "AUTHOR")) {
			let args = controller->parseShort("AUTHOR", line);
			if (isset(args[0])) {
				return "<meta name=\"author\" content=\"" . this->cleanArg(args[0]) . "\">";
			}

			return "";
		} elseif (this->match(line, "VIEWPORT")) {
			let args = controller->parseShort("VIEWPORT", line);
			if (isset(args[0])) {
				return "<meta name=\"viewport\" content=\"" . this->cleanArg(args[0]) . "\">";
			}

			return "";
		} elseif (this->match(line, "FAVICON")) {
			let args = controller->parseShort("FAVICON", line);
			if (isset(args[0])) {
				var output = "<link rel=\"icon\" href=\"" . this->cleanArg(controller->processGlobals(args[0], globals)) . "\"";
				if (isset(args[1])) {
					let output = output . " sizes=\"" . this->cleanArg(args[1]) . "\"";
				}
				return output . ">";
			}

			return "";
		}

		return null;
	}
}
