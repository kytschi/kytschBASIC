/**
 * LINE parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Shapes\Line
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2026 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.2
 *
 */
namespace KytschBASIC\Libs\Arcade\Parsers\Shapes;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Line extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch (command) {
			case "LINE":
				return this->parseLine(args);
			default:
				return null;
		}
	}

	public function parseLine(array args)
	{
		var output = "";

		if (count(args) < 4) {
			throw new Exception("Invalid LINE");
		}

		let output = "<?php
		if (!isset($KBBITMAPID)) {
			throw new KytschBASIC\\Exceptions\\Exception(\"BITMAP is not defined\");
		}
		$KBSHAPES[] = [
			'colour' => $KBRGB,
			'shape' => 'imageline',
			'id' => '',
			'x1' => 0,
			'y1' => 0,
			'x2' => 50,
			'y2' => 50
		];";

		if (!empty(args[0]) && args[0] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['x1'] = intval(\"" . this->outputArg(args[0], false, false) . "\");";
		}

		if (!empty(args[1]) && args[1] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['y1'] = intval(\"" . this->outputArg(args[1], false, false) . "\");";
		}

		if (!empty(args[2]) && args[2] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['x2'] = intval(\"" . this->outputArg(args[2], false, false) . "\");";
		}

		if (!empty(args[3]) && args[3] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['y2'] = intval(\"" . this->outputArg(args[3], false, false) . "\");";
		}

		if (isset(args[4]) && !empty(args[4]) && args[4] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['id'] = \"" . this->outputArg(args[4], false, false) . "\";";
		}

		return output . "?>";
	}
}
