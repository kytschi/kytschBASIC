/**
 * Strings helper
 *
 * @package     KytschBASIC\Helpers\Strings
 * @author 		Mike Welsh
 * @copyright   2026 Mike Welsh
 * @version     0.0.1
 *
 */
namespace KytschBASIC\Helpers;

class Strings
{
	public static function minify(string str) -> string
	{
		// Remove newlines, tabs, and carriage returns
		let str = str_replace(["\r\n", "\r", "\n", "\t"], " ", str);

		// Collapse multiple spaces into one
		let str = preg_replace("/  +/", " ", str);

		// Remove spaces around structural CSS characters
		let str = preg_replace("/\s*([\{\}:;,>~\+])\s*/", "$1", str);

		// Remove the last semicolon before a closing brace
		let str = str_replace(";}", "}", str);

		return trim(str);
	}

	public static function random(int length = 16) -> string
	{
		var keyspace, str = "", key;

		let keyspace = [
			"1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
			"A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", 
			"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "x", "y", "z"
		];
	
        while (strlen(str) < (length + 1)) {
            let key = rand(0, count(keyspace) - 1);
            let str .= keyspace[key];
		}

		return str;
	}
}
