/**
 * Database exception
 *
 * @package     KytschBASIC\Exceptions\DatabaseException
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

use KytschBASIC\Exceptions\Exception;

class DatabaseException extends Exception
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
}
