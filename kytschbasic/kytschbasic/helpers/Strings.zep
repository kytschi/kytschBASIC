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
}
