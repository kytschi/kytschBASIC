/**
 * Generic exception
 *
 * @package     KytschBASIC\Exceptions\Exception
 * @author 		Mike Welsh
 * @copyright   2025 Mike Welsh
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
namespace KytschBASIC\Exceptions;

class Exception extends \Exception
{
    public code;
    private version = "0.0.17 alpha";
    private html;
    private line_no = 0;
    
	public function __construct(string message, code = 500, bool html = true, line = 0)
	{
        if (is_string(code)) {
            let code = 500;
        }

        //Trigger the parent construct.
        parent::__construct(message, code);

        let this->code = code;
        let this->html = html;
        let this->line_no = line;
    }

    public function getLineNo()
    {
        return this->line_no;
    }

    /**
     * Override the default string to we can have our grumpy cat.
     */
    public function __toString()
    {
        var message;

        if (defined("VERSION")) {
            let this->version = constant("VERSION");
        }

        if (this->html) {
            let message = this->gfx(this->getCode()) . 
                "<p>&nbsp;&nbsp;<pre style='padding-left:10px'>" . this->getMessage() . "</pre><br/>" . 
                "&nbsp;&nbsp;<small><muted>kytschBASIC " . this->version . "</muted></small></p>";
        } else {
            let message = this->gfx(this->getCode()) . "\n" . this->getMessage() . "\n";
        }

        return message;
    }

    /**
     * Fatal error just lets us dumb the error out faster and kill the site
     * so we can't go any futher.
     */
    public function fatal(string template = "", line = 0)
    {
        if (this->html && !headers_sent()) {
            switch (this->code) {
                case 404:
                    header("HTTP/1.0 404 Not Found");
                    break;
                default:
                    header("HTTP/1.0 500 Internal Server Error");
                    break;
            }
        }

        if (!line) {
            let line = this->line_no;
        }
        
        this->jsOutput();
        echo this;
        if (template && line) {
            if (this->html) {
                echo "<p>&nbsp;&nbsp;<strong>Trace</strong><br/>&nbsp;&nbsp;Source <strong>" .
                    str_replace(getcwd(), "", template) . "</strong> at line <strong>" . line . "</strong></p>";
            } else {
                echo "Trace:\n";
                echo str_replace(getcwd(), "", template) . " at line " . line . "\n";
            }
        }
        die();
    }

    /**
     * Generate the grumpy cat, I mean just look at him!
     */
    private function gfx(code)
    {
        if (!code) {
            let code = 500;
        }

        var gfx = "<pre>";

        if (!this->html) {
            let gfx = "";
        }

        let gfx .= "
         ⡴⠶⣆⠠⠤⣤⠤⠤⠤⠤⠤⠤⠀⠤⣔⠒⢀⡨⠛⢵⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢸⠃⠀⣾⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⠀⢸⡇⠀
⠀⠀⠀⠀⠀⠀⠀⢸⡄⡠⠃⠀⠀⠀⠀⠈⠆⠀⠀⠂⠀⠀⠀⠀⠀⠀⠱⣸⡇⠀
⠀⠀⠀⠀⠀⠀⠀⠸⡝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⠁⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢧⢀⣀⣀⣀⣒⣀⣀⡲⠀⠀⣂⣀⣀⣒⣂⣀⣀⡀⢸⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢸⠈⢫⣍⡻⢟⣉⠽⠳⣖⣲⠞⠫⣁⡛⢋⣠⠜⠁⢸⠀⠀   ⢰⣷⡀⠀⠀⣿⣿⠀⣠⣴⣾⣿⣶⣦⡀⠀⣶⣶⣶⣶⣶⡄⣶⣶⣶⣶⣶⡆⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠉⠋⠁⠀⢀⡡⠚⠓⢄⡀⠀⠀⠁⠁⠀⠀⢸⠀⠀   ⢸⣿⣿⣄⠀⣿⣿⣼⣿⠋⠀⠀⠈⠻⣿⡆⣿⣇⠀⠀⢹⣿⣿⣿⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠘⣄⠀⠀⠀⠀⢄⠏⠀⠐⠀⠀⠸⠂⡄⠀⠀⠀⠀⡼⠀⠀   ⢸⣿⠙⣿⣦⣿⣿⣿⣇⠀⠀⠀⠀⠀⣿⡷⣿⣿⣤⣴⣿⠟⣿⣿⠿⠿⠿⠇⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠑⢄⠀⠀⠀⠁⠀⠀⠀⠀⠀⠁⠀⠀⠀⡴⠋⡇⠀⠀   ⢸⣿⠀⠈⢿⣿⣿⠹⣿⣦⣀⣀⣠⣼⡿⠃⣿⡯⠉⠉⠁⠀⣿⣿⣀⣀⣀⡀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠑⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠃⠀⠀   ⠘⠛⠀⠀⠀⠛⠛⠀⠈⠛⠻⠿⠟⠋⠁⠀⠛⠓⠀⠀⠀⠀⠛⠛⠛⠛⠛⠃⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⢰⠀⠀⠀⠀⠀⠀⠀⠀⢀⠃⠀⠀⠀⡀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⡆⠀⠀⠀⠀⠑⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⡷⡀⠀   Error Code: " . code . "
⠀⠀⠀⠀⠀⠀⠀⢠⠊⢱⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⠁⠈⢆
⠀⢀⠤⠐⠒⠉⠉⡇⡠⠤⣇⠀⠀⠀⠀⠀⡿⠀⠀⠀⢻⠀⠀⠀⠀⢰⡡⠒⢄⡸
⡰⠁⠀⣀⣄⣀⡀⢹⣱⡞⡜⡄⠀⠀⠀⠀⡇⠁⠀⠊⢠⠀⠀⠀⢀⠏⠰⡲⣮⣷
⢇⠀⠀⠀⠀⠈⢹⠉⠚⠒⢣⠼⣀⠀⠀⠀⡐⠉⠉⠉⠹⡀⠀⠀⡀⢯⣳⠊⠀⠀
⠈⠢⢀⣀⣀⠤⠃⠀⠀⠀⠳⠧⠄⠬⠤⠔⠁⠀⠀⠀⠀⠑⠂⠀⠓⠊⠀⠀⠀⠀";

        if (this->html) {
            let gfx .= "</pre>";
        }

        return gfx;
    }

    private function jsOutput()
    {
        var splits;
        let splits = explode("Stack trace:", this->getMessage());
    
        echo "<script type=\"text/javascript\">console.log('[KB ERROR]', '" . trim(splits[0]) . "');</script>";
    }
}
