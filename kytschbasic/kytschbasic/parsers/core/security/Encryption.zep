/**
 * Encryption parser
 *
 * @package     KytschBASIC\Parsers\Core\Security\Encryption
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.1
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
namespace KytschBASIC\Parsers\Core\Security;

use KytschBASIC\Parsers\Core\Command;

class Encryption extends Command
{
	public function processHash(arg)
	{
		var splits, cleaned;

		let splits = this->equalsSplit(arg);

		if (count(splits) > 1) {
			let cleaned = this->cleanArg("HASH", splits[1]);
			return str_replace(splits[1], "password_hash(" . cleaned . ", PASSWORD_DEFAULT)", arg);
		}

		return "password_hash(" . this->cleanArg("HASH", arg) . ", PASSWORD_DEFAULT)";
	}

	public function processHashVerify(arg)
	{
		var splits, cleaned, args;

		let splits = this->equalsSplit(arg);
		
		if (count(splits) > 1) {
			let cleaned = this->cleanArg("HASHVERIFY", splits[1]);
			let args = this->args(cleaned);

			let args[1] = trim(args[1], "\"");
			if (!this->isVariable(args[1])) {
				let args[1] = "'" . args[1] . "'";
			}
			
			return str_replace(splits[1], "password_verify(" . args[0] . ", '" . args[1] . "')", arg);
		}

		let args = this->cleanArg("HASHVERIFY", arg);

		return "password_verify(" . args[0] . ", '" . args[1] . "')";
	}

	public function processUUID(arg)
	{
		var splits, cleaned, uuid, data = [];

        let data = random_bytes(16);
		
		//let data[6] = chr(ord(data[6]) & 0x0f | 0x40);
		//let data[8] = chr(ord(data[8]) & 0x3f | 0x80);
		let uuid = vsprintf("%s%s-%s-%s-%s-%s%s%s", str_split(bin2hex(data), 4));

		let splits = this->equalsSplit(arg);
		if (count(splits) > 1) {
			let cleaned = this->cleanArg("UUID", splits[1]);
			return str_replace(splits[1], "\"" . uuid . "\"", arg);
		}

		return "\"" . uuid . "\"";
	}
}
