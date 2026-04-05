/**
 * Command parser
 *
 * @package     KytschBASIC\Parsers\Core\Command
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.2
 *
 */
namespace KytschBASIC\Parsers\Core;

use KytschBASIC\Parsers\Core\Variables;

class Command extends Variables
{
	public function genID(string id)
	{
		return id . "-" . hrtime(true);
	}
}
