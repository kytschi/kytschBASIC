/**
 * WINDOW parser
 *
 * @package     KytschBASIC\Libs\Arcade\Parsers\Screen\Window
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.2
 *
 * Copyright 2025 Mike Welsh
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

	private function genWindowStyle(string id = "")
	{
		var output = "";

		let output = "<style>\n";
		let output .= id . " {display: flex; flex-direction: column; background-color: rgba(136,136,136,1);color:rgb(0,0,0);border: 1px solid rgb(91,91,91);height: 100vh;width:100%;}\n";
		let output .= id . " .window-title {display: flex; overflow: hidden; height: 30px; padding: 10px; background-color: rgba(221,17,68,1);color:rgb(255,255,255);border-bottom: 1px solid rgb(91,91,91);}\n";
		let output .= id . " .window-title span {display: block;}\n";
		let output .= "</style>\n";

		return output;
	}

	public function parseWindow(array args)
	{
		var output = "", id, class_name = "", title="Window Title";

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let id = args[1];
		} else {
			let id = this->genID("kb-window");
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let class_name = args[2];
		}

		if (class_name) {
			let output = this->genWindowStyle("." . this->outputArg(class_name, true, false));
		} else {
			let output = this->genWindowStyle("#" . this->outputArg(id, true, false));
		}
		
		let output .= "<?php $KB_WINDOW_ID=\"" . this->outputArg(id, false, false). "\"; ?>\n<?= \"<div";

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let title = args[0];
			let output .= " title=" . this->outputArg(title, false);
		}

		let output .= " id=" . this->outputArg(id, false);
		if (class_name) {
			let output .= " class=" . this->outputArg(class_name, false);
		}

		let output .= "><div class='window-title'><span>" . this->outputArg(title, false, false) . "</span></div>\"; ?>";
		
		return output;
	}

	public function parseWindowBody(array args)
	{
		var output = "", id = "";

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let id = args[0];
		} else {
			let id = this->genID("kb-window-body");
		}

		let output = "<style>\n";
		let output .= "#<?= $KB_WINDOW_ID; ?> #" . this->outputArg(id, true, false) . " {flex-grow: 1; width: 100%; overflow: hidden; background-color: rgba(255,255,255,1);color:rgb(0,0,0);}\n";
		let output .= "</style>\n";
		let output .= "<?= \"<div";
		let output .= " id=" . this->outputArg(id, false);

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let output .= " class=" . this->outputArg(args[1], false);
		}

		let output .= ">\"; ?>";
		
		return output;
	}

	public function parseWindowFooter(array args)
	{
		var output = "", id = "";

		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let id = args[0];
		} else {
			let id = this->genID("kb-window-footer");
		}

		let output = "<style>\n";
		let output .= "#" . this->outputArg(id, true, false) . " {display: flex; overflow: hidden; height: 30px; padding: 10px; background-color: rgba(229,229,229,1);color:rgb(0,0,0);border-top: 1px solid rgb(91,91,91);}\n";
		let output .= "#" . this->outputArg(id, true, false) . " span {display: block;}\n";
		let output .= "</style>\n";

		let output .= "<?= \"<div";
		let output .= " id=" . this->outputArg(id, false);

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let output .= " class=" . this->outputArg(args[1], false);
		}

		let output .= ">\"; ?>";
		
		return output;
	}
}
