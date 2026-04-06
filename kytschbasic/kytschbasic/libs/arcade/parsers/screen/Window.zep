/**
 * WINDOW parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Screen\Window
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2026 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.2
 *
 */
namespace KytschBASIC\Libs\Arcade\Parsers\Screen;

use KytschBASIC\Parsers\Core\Command;

class Window extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch(command) {
			case "WINDOWBODY":
				return this->parseWindowBody(args);
			case "WINDOWFOOTER":
				return this->parseWindowFooter(args);
			case "WINDOW":
				return this->parseWindow(args);
			case "END WINDOWBODY":
				return "</div>";
			case "END WINDOWFOOTER":
				return "</div>";
			case "END WINDOW":
				return "</div>";
			default:
				return null;
		}
	}

	public function parseWindow(array args)
	{
		var output = "", id, class_name = "kb-window", title="";

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let id = args[1];
		} else {
			let id = this->genID("kb-window");
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let class_name = args[2];
		}
		
		let output .= "<?= \"<div";

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let title = args[0];
			let output .= " title=" . this->outputArg(title, false);
		}

		let output .= " id=" . this->outputArg(id, false);
		if (class_name) {
			let output .= " class=" . this->outputArg(class_name, false);
		}

		let output .= ">";
		if (title) {
			let output .= "<div class='kb-window-title'><span>" . this->outputArg(title, false, false) . "</span></div>";
		}
		
		return output . "\"; ?>";
	}

	public function parseWindowBody(array args)
	{
		var output = "", id = "", class_name = "kb-window-body";

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let id = args[0];
		} else {
			let id = this->genID("kb-window-body");
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let class_name = args[1];
		}

		let output .= "<?= \"<div";
		let output .= " id=" . this->outputArg(id, false);
		if (class_name) {
			let output .= " class=" . this->outputArg(class_name, false);
		}

		let output .= ">\"; ?>";
		
		return output;
	}

	public function parseWindowFooter(array args)
	{
		var output = "", id = "", class_name = "kb-window-footer";

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let id = args[0];
		} else {
			let id = this->genID("kb-window-footer");
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let class_name = args[1];
		}

		let output .= "<?= \"<div";
		let output .= " id=" . this->outputArg(id, false);
		if (class_name) {
			let output .= " class=" . this->outputArg(class_name, false);
		}

		let output .= ">\"; ?>";
		
		return output;
	}
}
