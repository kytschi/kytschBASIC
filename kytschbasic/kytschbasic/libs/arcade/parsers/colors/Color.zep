/**
 * COLOR parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Colors\Color
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2026 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.2
 *
 */
namespace KytschBASIC\Libs\Arcade\Parsers\Colors;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Color extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch (command) {
			case "RGB":
				return this->processRGB(args);
			default:
				return null;
		}
	}

	public function processRGB(args)
	{
		var output = "<?php $KBRGB=[";

		if (count(args) < 3) {
			throw new Exception("Invalid RGB");
		}
						
		if (!empty(args[0]) && args[0] != "\"\"") {
			let output .= "intval(\"" . this->outputArg(args[0], false, false) . "\"),";
		} else {
			let output .= "0,";
		}

		if (!empty(args[1]) && args[1] != "\"\"") {
			let output .= "intval(\"" . this->outputArg(args[1], false, false) . "\"),";
		} else {
			let output .= "0,";
		}

		if (!empty(args[2]) && args[2] != "\"\"") {
			let output .= "intval(\"" . this->outputArg(args[2], false, false) . "\"),";
		} else {
			let output .= "0,";
		}

		if (isset(args[3]) && !empty(args[3]) && args[3] != "\"\"") {
			let output .= "intval((intval(\"" . this->outputArg(args[3], false, false) . "\") - 1) / 2),";
		} else {
			let output .= "0,";
		}

		return rtrim(output, ",") . "];?>";
	}
}
