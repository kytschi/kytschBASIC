/**
 * Generic exception
 *
 * @package     KytschBASIC\Exceptions\Exception
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
namespace KytschBASIC\Exceptions;

class Exception extends \Exception
{
    public code;
    public version;

	public function __construct(string message, int code = 500, string version = "0.0.7 alpha")
	{
        //Trigger the parent construct.
        parent::__construct(message, code);

        let this->version = version;
        let this->code = code;
    }

    /**
     * Override the default string to we can have our grumpy cat.
     */
    public function __toString()
    {
        var message;

        let message = this->gfx(this->getCode()) . 
            "<p>&nbsp;&nbsp;<strong>" . this->getMessage() . "</strong><br/>" . 
            "&nbsp;&nbsp;<small><muted>kytschBASIC " . this->version . "</muted></small></p>";

        return message;
    }

    /**
     * Fatal error just lets us dumb the error out faster and kill the site
     * so we can't go any futher.
     */
    public function fatal(string template = "", int line = 0)
    {
        switch (this->code) {
            case 404:
                header("HTTP/1.0 404 Not Found");
                break;
            default:
                header("HTTP/1.0 500 Internal Server Error");
                break;
        }
        
        echo this;
        if (template && line) {
            echo "<br/><p><strong>Trace</strong><br/>Source <strong>" . template . "</strong> at line <strong>" . line . "</strong></p>";
        }
        die();
    }

    /**
     * Generate the grumpy cat, I mean just look at him!
     */
    private function gfx(int code)
    {
        if (!code) {
            let code = 500;
        }

        var gfx;

        let gfx = "<pre>
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
⠈⠢⢀⣀⣀⠤⠃⠀⠀⠀⠳⠧⠄⠬⠤⠔⠁⠀⠀⠀⠀⠑⠂⠀⠓⠊⠀⠀⠀⠀</pre>";

        return gfx;
    }
}
