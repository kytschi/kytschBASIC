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
		return "<?php $KBSHAPES[] = [
			'colour' => $KBRGB,
			'shape' => '" . (filled ? "imagefilledellipse" : "imagearc") . "',
			'x' => " . (isset(args[0]) ? intval(args[0]) : 0) . ",
			'y' => " . (isset(args[1]) ? intval(args[1]) : 0) . ",
			'width' => " . (isset(args[2]) ? intval(args[2]) : 10) . ",
			'height' => " . (isset(args[2]) ? intval(args[2]) : 10) . ",
			's_angle' => 0,
			'e_angle' => 360,
		]; ?>";
	}
}
