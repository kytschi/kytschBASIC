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

use KytschBASIC\Parsers\Arcade\Colors\Rgb;
use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Session;

class Shape extends Command
{
	protected x=0;
	protected y=0;

	protected width=0;
	protected height=0;

	protected radius=10;
	protected start_angle=10;
	protected end_angle=10;
	protected red=0;
	protected green=0;
	protected blue=0;
	protected transparency=0;
	protected colour = "";

	protected command = "";
	protected event_manager = null;
	protected globals = [];
	protected config = null;

	public function __construct(
		string command,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		let this->command = command;
		let this->event_manager = event_manager;
		let this->globals = globals;
		let this->config = config;

		this->build();
	}

	public function build()
	{
		return null;
	}

	public function genColour()
	{	
		var output, controller;
		let controller = new Rgb();
		let output = controller->code();

		return output .
			"<?php $KBCOLOUR = imagecolorallocatealpha($KBIMAGE, $red, $green, $blue, " .
			this->transparency .
			");?>";
	}

	public function getBlue()
	{
		return this->blue;
	}

	public function getEndAngle()
	{
		return this->end_angle;
	}

	public function getGreen()
	{
		return this->green;
	}

	public function getHeight()
	{
		return this->height;
	}

	public function getRadius()
	{
		return this->radius;
	}

	public function getRed()
	{
		return this->red;
	}

	public function getStartAngle()
	{
		return this->start_angle;
	}

	public function getTransparency()
	{
		return this->transparency;
	}

	public function getWidth()
	{
		return this->width;
	}

	public function getX()
	{
		return this->x;
	}

	public function getY()
	{
		return this->y;
	}

	public function move(string command)
	{
		var args;
		let args = this->parseArgs("MOVE SHAPE", command);

		if (isset(args[0])) {
			let this->x = intval(args[0]);
		}

		if (isset(args[1])) {
			let this->y = intval(args[1]);
		}
	}

	public function setTransparency(string command)
	{
		var args;
		let args = this->parseArgs("SET TRANSPARENCY", command);

		if (isset(args[0])) {
			let this->transparency = intval(args[0]);
		}
	}

	public function transparency(value)
	{
		var percent;
		let percent = intval(value) / 100;
		if (percent != 0) {
			return intval(percent * 127);
		} else {
			return 0;
		}
	}
}
