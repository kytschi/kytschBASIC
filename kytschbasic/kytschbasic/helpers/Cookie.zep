/**
 * Cookie helper
 *
 * @package     KytschBASIC\Helpers\Cookie
 * @author 		Mike Welsh
 * @copyright   2022 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2022 Mike Welsh
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
namespace KytschBASIC\Helpers;

class Cookie
{
	private cookie_name = "kb_HLPR";

	private function getCookie()
	{
		if (!array_key_exists(this->cookie_name, _COOKIE)) {
			return null;
		}

		var cookie = _COOKIE[this->cookie_name];
		if (cookie) {
			let cookie = json_decode(str_replace("\\\"", "\"", trim(cookie, "\"")));
		} else {
			let cookie = json_decode("{display:[0,0]}");
		}

		return cookie;
	}

	public function get(string name)
	{
		var cookie = this->getCookie();

		if (isset(cookie->{name})) {
			return cookie->{name};
		}

		return null;
	}
}
