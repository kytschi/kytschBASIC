/**
 * Files parser
 *
 * @package     KytschBASIC\Parsers\Core\Media\Files
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2026 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.1
 *
 */
namespace KytschBASIC\Parsers\Core\Media;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Files extends Command
{
	public function parse(string line, string command, array args, bool in_javascript = false, in_event = false)
	{
		switch(command) {
			case "COPYFILE":
				return this->processCopyFile(args);
			case "COPYUPLOAD":
				return this->processCopyFileUpload(args);
			case "OUTPUTFILE":
				return this->processOutputFile(args);
			case "WRITEFILE":
				return this->processWriteFile(args);
			default:
				return null;
		}	
	}

	private function processCopyFile(array args)
	{
		var output = "<?php copy(\"";
				
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= this->outputArg(args[0], false);
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let output .= "\", \"". this->outputArg(args[1], false);
		}

		return output . "\"); ?>";
	}

	private function processCopyFileUpload(array args)
	{
		if (!isset(args[0]) || empty(args[0]) || args[0] == "\"\"") {
			throw new Exception("Invalid COPYUPLOAD, missing required parameters");
		}

		if (!isset(args[1]) || empty(args[1]) || args[1] == "\"\"") {
			throw new Exception("Invalid COPYUPLOAD, missing required parameters");
		}

		let args[0] = trim(args[0], "\"");
		//let args[1] = trim(args[1], "\"");
		
		return "
		<?php if (!empty($_FILES) && isset($_FILES['" . args[0] . "'])) {
			if (isset($_FILES['" . args[0] . "']['tmp_name'])) {
				if (!move_uploaded_file(
					$_FILES['" . args[0] . "']['tmp_name'],
					" . args[1] . "
				)) {
					throw new Exception('Invalid COPYUPLOAD, failed to move the upload');
				}
			}
		} ?>";
	}

	private function processOutputFile(array args)
	{
		var output = "<?php ", printing = 1;

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let output .= args[1] . " = ";
			let printing = 0;
		} else {
			let output .= "printf(";
		}

		let output .= "file_get_contents(";
				
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= args[0];
		}

		if (printing) {
			let output .= ")";
		}

		return output . "); ?>";
	}

	private function processWriteFile(array args)
	{
		var output = "<?php file_put_contents(";
				
		if (isset(args[0]) && !empty(args[0]) && args[0] != "\"\"") {
			let output .= args[0];
		}

		if (isset(args[1]) && !empty(args[1]) && args[1] != "\"\"") {
			let output .= ", \"". this->outputArg(args[1], false) . "\"";
		}

		if (isset(args[2]) && !empty(args[2]) && args[2] != "\"\"") {
			let output .= ", FILE_APPEND";
		}

		return output . "); ?>";
	}
}
