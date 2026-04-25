/**
 * CIRCLE parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Shapes\Circle
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2026 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.1
 *
 */
namespace KytschBASIC\Libs\Arcade\Parsers\Shapes;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Circle extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch (command) {
			case "CIRCLE":
				return this->parseCircle(args);
			case "CIRCLEF":
				return this->parseCircle(args, true);
			default:
				return null;
		}
	}

	public function parseCircle(array args, bool filled = false)
	{
		var output = "";

		if (count(args) < 3) {
			throw new Exception("Invalid CIRCLE" . (filled ? "F" : ""));
		}

		let output = "<?php
		if (!isset($KBBITMAPID)) {
			throw new KytschBASIC\\Exceptions\\Exception(\"BITMAP is not defined\");
		}
		$KBSHAPES[] = [
			'colour' => $KBRGB,
			'shape' => '" . (filled ? "imagefilledellipse" : "imageellipse") . "',
			'id' => '',
			'x' => 0,
			'y' => 0,
			'width' => 50,
			'height' => 50
		];";

		if (!empty(args[0]) && args[0] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['x'] = intval(\"" . this->outputArg(args[0], false, false) . "\");";
		}

		if (!empty(args[1]) && args[1] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['y'] = intval(\"" . this->outputArg(args[1], false, false) . "\");";
		}

		if (!empty(args[2]) && args[2] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['width'] = intval(\"" . this->outputArg(args[2], false, false) . "\");";
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['height'] = intval(\"" . this->outputArg(args[2], false, false) . "\");";
		}

		if (isset(args[3]) && !empty(args[3]) && args[3] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['id'] = \"" . this->outputArg(args[3], false, false) . "\";";
		}

		return output . "?>";
	}
}
