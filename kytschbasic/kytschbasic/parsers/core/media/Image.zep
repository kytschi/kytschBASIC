/**
 * Image parser
 *
 * @package     KytschBASIC\Parsers\Core\Media\Image
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
namespace KytschBASIC\Parsers\Core\Media;

use KytschBASIC\Parsers\Core\Command;

class Image extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch(command) {
			case "IMAGE":
				return this->processImage(args);
			default:
				return null;
		}	
	}

	private function processImage(array args)
	{
		var output = "<?= \"<image";		
				
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= " src=" . this->outputArg(args[0], false);
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let output .= " title=" . this->outputArg(args[1], false);
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let output .= " class=" . this->outputArg(args[2], false);
		}

		if (isset(args[3]) && !empty(args[3]) && args[3] != "\"\"") {
			let output .= " id=" . this->outputArg(args[3], false);
		}

		return output . "/>\"; ?>";
	}
}
