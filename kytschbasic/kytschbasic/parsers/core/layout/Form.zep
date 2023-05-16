/**
 * Form parser
 *
 * @package     KytschBASIC\Parsers\Core\Layout\Form
 * @author 		Mike Welsh
 * @copyright   2023 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2023 Mike Welsh
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
namespace KytschBASIC\Parsers\Core\Layout;

use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Command;

class Form extends Command
{
	protected id = "";
	protected _class = "";

	public function parse(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		if (this->match(command, "FORM CLOSE")) {
			return "</form>";
		} elseif (this->match(command, "FORM INPUT")) {
			return this->processInput(command, event_manager, globals);
		} elseif (this->match(command, "FORM TEXTAREA")) {
			return this->processTextarea(command, event_manager, globals);
		} elseif (this->match(command, "FORM SUBMIT CLOSE")) {
			return "</button>";
		} elseif (this->match(command, "FORM SUBMIT")) {
			return this->processButton(command, event_manager, globals, "submit");
		} elseif (this->match(command, "FORM CAPTCHA")) {
			return this->processCaptcha(command, event_manager, globals, config);
		} elseif (this->match(command, "FORM")) {
			return this->processForm(command, event_manager, globals);
		}

		return null;
	}

	private function processButton(
		string command,
		event_manager,
		array globals,
		string type = "button"
	) {
		let this->id = this->genID("kb-button");

		var args, arg, params="", label="", html, controller;
		let controller = new Args();
		let args = controller->parseShort(strtoupper("form submit"), command);

		let params .= " type=\"" . type . "\"";

		if (isset(args[0])) {
			let arg = controller->clean(args[0]);
			if (!empty(arg)) {
				let params .= " name=\"" . arg . "\"" . " value=\"" . arg . "\"";
			}
		}

		if (isset(args[1])) {
			let arg = controller->clean(args[1]);
			if (!empty(arg)) {
				let label = arg;
			}
		}

		if (isset(args[2])) {
			let arg = controller->clean(args[2]);
			if (!empty(arg)) {
				let this->_class = arg;
				let params .= " class=\"" . this->_class . "\"";
			}
		}

		if (isset(args[3])) {
			let arg = controller->clean(args[3]);
			if (!empty(arg)) {
				let this->id = arg;
			}
		}

		let params .= " id=\"" . this->id . "\"";

		let params .= controller->leftOver(4, args);
		let html = "<button " . params . ">";
		if (label != "") {
			let html .= label . "</button>";
		}

		return html;
	}

	private function processCaptcha(
		string command,
		event_manager,
		array globals,
		var config = null
	) {
		var colour, red, green, blue, width, height, image, keyspace, pieces, max, trans_colour;
		let colour = "000000";

        if (strlen(colour) == 6) {
            let red = hexdec(substr(colour, 0, 2));
            let green = hexdec(substr(colour, 2, 2));
            let blue = hexdec(substr(colour, 4, 2));
        } elseif (strlen(colour) == 3) {
            let red = hexdec(substr(colour, 0, 1));
            let green = hexdec(substr(colour, 1, 1));
            let blue = hexdec(substr(colour, 3, 1));
        } else {
            let red = 0;
            let green = 0;
            let blue = 0;
        }

        let width = 340;
        let height = 100;

        let image = imagecreatetruecolor(width, height);
        imagesavealpha(image, true);

        let trans_colour = imagecolorallocatealpha(image, 0, 0, 0, 127);
        imagefill(image, 0, 0, trans_colour);

        let keyspace = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];

        let pieces = [];
        let max = count(keyspace) - 1;

		var i, captcha, font_colour, image_data, line_color, letter = "", encrypted;

		let i = 7;
		while i {
            if (random_int(0, 1)) {
                let letter = keyspace[random_int(0, max)];
            } else {
                let letter = strtolower(keyspace[random_int(0, max)]);
            }
            let pieces[] = letter;
			let i -= 1;
        }

        let captcha = implode("", pieces);

        let font_colour = imagecolorallocate(image, red, green, blue);
        imagefttext(
           	image,
            38,
            0,
            15,
            65,
            font_colour,
            getcwd() . "/" . ltrim(config["assets"]->captcha_font, "/"),
            captcha
        );		

		let i = 20;
		while i {
            let line_color = imagecolorallocatealpha(image, red, green, blue, rand(10, 100));
            imageline(image, rand(0, width), rand(0, height), rand(0, width), rand(0, height), line_color);
			let i -= 1;
        }

        ob_start();
        imagepng(image);
        let image_data = ob_get_contents();
        ob_end_clean();

        mt_srand(mt_rand(100000, 999999));
		
		var iv;
		let iv = openssl_random_pseudo_bytes(openssl_cipher_iv_length("AES-128-CBC"));

        let encrypted = openssl_encrypt(
            "_KBCAPTCHA=" . captcha . "=" . (time() + 1 * 60),
            "aes128",
            captcha,
			0,
			iv
        ) . base64_encode(iv);
		
        imagedestroy(image);

		return "<div class=\"kb-captcha-img\"><img src=\"data:image/png;base64," . base64_encode(image_data) . "\" alt=\"captcha\"/></div>" .
			"<input name=\"kb-captcha\" class=\"kb-captcha-input\" required/>" .
			"<input name=\"_KBCAPTCHA\" type=\"hidden\" value=\"" . encrypted . "\"/>";
	}

	private function processInput(
		string command,
		event_manager,
		array globals
	) {
		let this->id = this->genID("kb-input");

		var args, arg, params="", controller;
		let controller = new Args();
		let args = controller->parseShort(strtoupper("form input"), command);

		if (isset(args[0])) {
			let arg = controller->clean(args[0]);
			if (!empty(arg)) {
				let params .= " name=\"" . arg . "\"";

				if (isset(_REQUEST[arg])) {
					let params .= " value=\"" . _REQUEST[arg] . "\"";
				}
			}
		}

		if (isset(args[1])) {
			let arg = controller->clean(args[1]);
			if (!empty(arg)) {
				let this->_class = arg;
				let params .= " class=\"" . this->_class . "\"";
			}
		}

		if (isset(args[2])) {
			let arg = controller->clean(args[2]);
			if (!empty(arg)) {
				let params .= " placeholder=\"" . arg . "\"";
			}
		}

		if (isset(args[3])) {
			let arg = controller->clean(args[3]);
			if (!empty(arg)) {
				let this->id = arg;
			}
		}

		if (isset(args[4])) {
			let arg = controller->clean(args[4]);
			if (!empty(arg)) {
				let params .= " required=\"required\"";
			}
		}

		let params = params . " id=\"" . this->id . "\"";

		let params = params . controller->leftOver(4, args);

		return "<input " . params . ">";
	}

	private function processTextarea(
		string command,
		event_manager,
		array globals
	) {
		let this->id = this->genID("kb-textarea");

		var args, arg, params="", text = "", controller;
		let controller = new Args();
		let args = controller->parseShort(strtoupper("form textarea"), command);

		if (isset(args[0])) {
			let arg = controller->clean(args[0]);
			if (!empty(arg)) {
				let params .= " name=\"" . arg . "\"";
				if (isset(_REQUEST[arg])) {
					let text = _REQUEST[arg];
				}
			}
		}

		if (isset(args[1])) {
			let arg = controller->clean(args[1]);
			if (!empty(arg)) {
				let this->_class = arg;
				let params .= " class=\"" . this->_class . "\"";
			}
		}

		if (isset(args[2])) {
			let arg = controller->clean(args[2]);
			if (!empty(arg)) {
				let params .= " placeholder=\"" . arg . "\"";
			}
		}

		if (isset(args[3])) {
			let arg = controller->clean(args[3]);
			if (!empty(arg)) {
				let this->id = arg;
			}
		}

		if (isset(args[4])) {
			let arg = controller->clean(args[4]);
			if (!empty(arg)) {
				let params .= " required=\"required\"";
			}
		}

		let params = params . " id=\"" . this->id . "\"";
		let params = params . controller->leftOver(4, args);

		return "<textarea " . params . ">" . text . "</textarea>";
	}

	private function processForm(
		string command,
		event_manager,
		array globals
	) {
		let this->id = this->genID("kb-form");

		var args, arg, params="", controller;
		let args = controller->parseShort(strtoupper("form"), command);

		if (isset(args[0])) {
			let arg = controller->clean(args[0]);
			if (!empty(arg)) {
				let this->id = arg;
			}
		}

		if (isset(args[1])) {
			let arg = controller->clean(args[1]);
			if (!empty(arg)) {
				if (!in_array(["get", "post"], strtolower(arg))) {
					let params .= " method=\"" . strtolower(arg) . "\"";
				} else {
					let params .= " method=\"get\"";
				}
			} else {
				let params .= " method=\"get\"";
			}
		}

		if (isset(args[2])) {
			let arg = controller->clean(args[2]);
			if (!empty(arg)) {
				let params .= " action=\"" . arg . "\"";
			}
		}

		if (isset(args[3])) {
			let arg = controller->clean(args[3]);
			if (!empty(arg)) {
				let this->_class = arg;
				let params .= " class=\"" . this->_class . "\"";
			}
		}

		let params .= " id=\"" . this->id . "\"";

		let params .= controller->leftOver(3, args);

		return "<form " . params . ">";
	}
}
