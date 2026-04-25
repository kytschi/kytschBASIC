/**
 * Shape parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Shapes\Shape
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2026 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.2
 *
 */
namespace KytschBASIC\Libs\Arcade\Parsers\Shapes;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Shape extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch (command) {
			case "COPYSHAPE":
				return this->parseCopy(args);
			case "DRAWSHAPE":
				return true;
			case "MOVESHAPE":
				return this->parseMove(args);
			default:
				return null;
		}
	}

	private function parseCopy(array args)
	{
		return "<?php 
		if (empty($KBSHAPES)) {
			throw new KytschBASIC\\Exceptions\\Exception(\"BITMAP is not defined\");
		}
		$KBSHAPES[] = $KBSHAPES[count($KBSHAPES) - 1];
		?>";
	}

	private function parseMove(array args)
	{
		return "<?php
		if (empty($KBSHAPES)) {
			throw new KytschBASIC\\Exceptions\\Exception(\"BITMAP is not defined\");
		}
		$KBSHAPES[count($KBSHAPES) - 1]['x']=" . intval(isset(args[0]) ? args[0] : 0) . ";
		$KBSHAPES[count($KBSHAPES) - 1]['y']=" . intval(isset(args[1]) ? args[1] : 0) . ";
		?>";
	}
}
