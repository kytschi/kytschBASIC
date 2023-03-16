/**
 * CIRCLE parser
 *
 * @package     KytschBASIC\Parsers\Arcade\Shapes\Shape
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
namespace KytschBASIC\Parsers\Arcade\Shapes;

use KytschBASIC\Parsers\Core\Args;
use KytschBASIC\Parsers\Core\Session;

class Shape
{
	protected static x=0;
	protected static y=0;

	protected static width=0;
	protected static height=0;

	protected static radius=10;
	protected static start_angle=10;
	protected static end_angle=10;
	protected static red=0;
	protected static green=0;
	protected static blue=0;
	protected static transparency=0;

	public function getBlue()
	{
		return self::blue;
	}

	public function getEndAngle()
	{
		return self::end_angle;
	}

	public function getGreen()
	{
		return self::green;
	}

	public function getRadius()
	{
		return self::radius;
	}

	public function getRed()
	{
		return self::red;
	}

	public function getTransparency()
	{
		return self::transparency;
	}

	public function getStartAngle()
	{
		return self::start_angle;
	}

	public function getX()
	{
		return self::x;
	}

	public function getY()
	{
		return self::y;
	}

	public static function move(
		var args,
		event_manager = null,
		array globals = []
	) {
		if (isset(args[0])) {
			let self::x = intval(args[0]);
		}

		if (isset(args[1])) {
			let self::y = intval(args[1]);
		}
	}

	public static function setTransparency(
		var args,
		event_manager = null,
		array globals = []
	) {
		if (isset(args[0])) {
			let self::transparency = intval(args[0]);
		}
	}
}
