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
	public static function parse(
		string line,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		var args;

		if (self::match(line, "HEAD CLOSE")) {
			return "</head>";
		} elseif (self::match(line, "HEAD") && !self::match(line, "HEADI")) {
			return "<head>";
		} elseif (self::match(line, "PALETTE")) {
			let args = Args::parseShort("PALETTE", line);
			if (isset(args[0])) {
				var str = "";
				let str = "<link rel=\"stylesheet\" type=\"text/css\" href=\"/" . self::cleanArg(args[0]) . "/css/palette.css";
				
				if (!empty(config["cache"])) {
					if (empty(config["cache"]->enabled)) {
						let str = str . "?no-cache=" . microtime();
					}
				}

				return str . "\">";				
			}

			return "";
		} elseif (self::match(line, "NAME")) {
			let args = Args::parseShort("NAME", line);
			if (isset(args[0])) {
				return "<title>" . self::cleanArg(args[0]) . "</title>";
			}

			return "";
		} elseif (self::match(line, "LANG")) {
			let args = Args::parseShort("LANG", line);
			if (isset(args[0])) {
				return "<html lang=\"" . self::cleanArg(args[0]) . "\">";
			}

			return "";
		} elseif (self::match(line, "CHARSET")) {
			let args = Args::parseShort("CHARSET", line);
			if (isset(args[0])) {
				return "<meta charset=\"" . self::cleanArg(args[0]) . "\">";
			}

			return "";
		} elseif (self::match(line, "DESCRIPTION")) {
			let args = Args::parseShort("DESCRIPTION", line);
			if (isset(args[0])) {
				return "<meta name=\"description\" content=\"" . self::cleanArg(args[0]) . "\">";
			}

			return "";
		} elseif (self::match(line, "KEYWORDS")) {
			let args = Args::parseShort("KEYWORDS", line);
			if (isset(args[0])) {
				return "<meta name=\"keywords\" content=\"" . self::cleanArg(args[0]) . "\">";
			}

			return "";
		} elseif (self::match(line, "AUTHOR")) {
			let args = Args::parseShort("AUTHOR", line);
			if (isset(args[0])) {
				return "<meta name=\"author\" content=\"" . self::cleanArg(args[0]) . "\">";
			}

			return "";
		} elseif (self::match(line, "VIEWPORT")) {
			let args = Args::parseShort("VIEWPORT", line);
			if (isset(args[0])) {
				return "<meta name=\"viewport\" content=\"" . self::cleanArg(args[0]) . "\">";
			}

			return "";
		} elseif (self::match(line, "FAVICON")) {
			let args = Args::parseShort("FAVICON", line);
			if (isset(args[0])) {
				var output = "<link rel=\"icon\" href=\"" . self::cleanArg(Args::processGlobals(args[0], globals)) . "\"";
				if (isset(args[1])) {
					let output = output . " sizes=\"" . self::cleanArg(args[1]) . "\"";
				}
				return output . ">";
			}

			return "";
		}

		return null;
	}
}
