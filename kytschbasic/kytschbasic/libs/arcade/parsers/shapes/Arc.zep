/**
 * ARC parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Shapes\Arc
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2026 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.3
 *
 */
namespace KytschBASIC\Libs\Arcade\Parsers\Shapes;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Arc extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch (command) {
			case "ARC":
				return this->parseArc(args);
			case "ARCF":
				return this->parseArc(args, true);
			default:
				return null;
		}
	}

	public function parseArc(array args, bool filled = false)
	{
		var output = "";

		if (count(args) < 5) {
			throw new Exception("Invalid ARC" . (filled ? "F" : ""));
		}

		let output = "<?php
		if (!isset($KBBITMAPID)) {
			throw new KytschBASIC\\Exceptions\\Exception(\"BITMAP is not defined\");
		}
		$KBSHAPES[] = [
			'colour' => $KBRGB,
			'shape' => '" . (filled ? "imagefilledarc" : "imagearc") . "',
			'id' => '',
			'x' => 0,
			'y' => 0,
			's_angle' => 0,
			'e_angle' => 10,
			'width' => 50,
			'height' => 10,
			'style' => IMG_ARC_NOFILL
		];";

		if (!empty(args[0]) && args[0] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['x'] = intval(\"" . this->outputArg(args[0], false, false) . "\");";
		}

		if (!empty(args[1]) && args[1] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['y'] = intval(\"" . this->outputArg(args[1], false, false) . "\");";
		}

		if (!empty(args[2]) && args[2] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['s_angle'] = intval(\"" . this->outputArg(args[2], false, false) . "\");";
		}

		if (!empty(args[3]) && args[3] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['e_angle'] = intval(\"" . this->outputArg(args[3], false, false) . "\");";
		}

		if (!empty(args[4]) && args[4] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['width'] = intval(\"" . this->outputArg(args[4], false, false) . "\");";
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['height'] = intval(\"" . this->outputArg(args[4], false, false) . "\");";
		}

		if (isset(args[5]) && args[5] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['style'] = intval(\"" . this->outputArg(args[5], false, false) . "\");";
		}

		if (isset(args[6]) && !empty(args[6]) && args[6] != "\"\"") {
			let output .= " $KBSHAPES[count($KBSHAPES) - 1]['id'] = \"" . this->outputArg(args[6], false, false) . "\";";
		}

		return output . "?>";
		
	}
}
