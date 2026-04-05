/**
 * SCREEN parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Screen\Screen
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2026 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.2
 *
 */
namespace KytschBASIC\Libs\Arcade\Parsers\Screen;

use KytschBASIC\Parsers\Core\Command;

class Screen extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch(command) {
			case "SCREEN":
				return this->parseScreen(args);
			case "END SCREEN":
				return "</div>";
			default:
				return null;
		}
	}

	public function parseScreen(array args)
	{
		var output = "", id = "", class_name = "kb-screen";

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let id = args[0];
		} else {
			let id = this->genID("kb-screen");
		}

		let output .= "<?= \"<div";
		let output .= " id=" . this->outputArg(id, false);
		if (class_name) {
			let output .= " class=" . this->outputArg(class_name, false);
		}
		
		return output . ">\"; ?>";
	}
}
