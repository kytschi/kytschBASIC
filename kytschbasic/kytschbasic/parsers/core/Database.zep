/**
 * Database parser
 *
 * @package     KytschBASIC\Parsers\Core\Database
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
namespace KytschBASIC\Parsers\Core;

use KytschBASIC\Exceptions\DatabaseException;
use KytschBASIC\Parsers\Core\Command;

class Database extends Command
{
	public function parse(string command, string args)
	{
		var err;

		try {
			if (command == "DOPEN") {
				return this->parseOpen(args);
			} elseif (command == "DFETCH") {
				return this->parseFetch(args);
			} elseif (command == "DREAD") {
				return this->parseRead(args);
			} elseif (command == "DSELECT") {
				return this->parseSelect(args);
			} elseif (command == "DWHERE") {
				return this->parseWhere(args);
			} elseif (command == "DSORT") {
				return this->parseSort(args);
			} elseif (command == "DBIND") {
				return this->parseBind(args);
			} elseif (command == "DJOIN") {
				return this->parseJoin(args);
			} elseif (command == "DLJOIN") {
				return this->parseLeftJoin(args);
			} elseif (command == "DRJOIN") {
				return this->parseRightJoin(args);
			} elseif (command == "DLIMIT") {
				return this->parseLimit(args);
			} elseif (command == "DSET") {
				return this->parseSet(args);
			} elseif (command == "DEXEC") {
				return this->parseExecute();
			} elseif (command == "END DATA") {
				return "";
			}
			
		} catch DatabaseException, err {
		    err->fatal();
		} catch \RuntimeException|\Exception, err {
		    throw new \Exception("Database error, " . err->getMessage());
		}
	}

	private function parseBind(args)
	{
		var arg, splits, output = "<?php ";
		let args = this->args(args);
		
		for arg in args {
			let splits = explode("=", arg);
			if (!empty(splits[0]) && !empty(splits[0])) {
				let output .= "$KBDBBIND['" . trim(splits[0]) . "'] = \"" . splits[1] . "\";";
			}
		}
		
		return output . " ?>";
	}

	private function parseExecute()
	{
		return "<?php
$KBDBSTATEMENT = $KBDBCONN->prepare(
	$KBDBSELECT . ($KBDBSELECT ? ' FROM ' : '') . $KBDBTABLE . $KBDBSET . $KBDBJOIN . $KBDBWHERE . $KBDBSORT . $KBDBLIMIT
);
$KBDBSTATEMENT->execute($KBDBBIND); ?>";
	}

	private function parseFetch(args)
	{
		let args = this->args(args);
		return this->parseExecute() . "\n<?php " . args[0] . " = $KBDBSTATEMENT->fetchAll(); ?>";
	}

	private function parseJoin(args)
	{
		let args = this->args(args);
		return "<?php $KBDBJOIN .= \" JOIN " . args[0] . "\"; ?>";
	}

	private function parseLeftJoin(args)
	{
		let args = this->args(args);
		return "<?php $KBDBJOIN .= \" LEFT JOIN " . args[0] . "\"; ?>";
	}

	private function parseLimit(args)
	{
		let args = this->args(args);
		return "<?php $KBDBLIMIT = \" LIMIT " . args[0] . "\"; ?>";
	}

	private function parseOpen(args)
	{
		var config, configs, dsn = "", item;
		let configs = constant("CONFIG");

		let args = this->args(args);
		let config = args[0];
		
		if (empty(configs["database"])) {
			throw new DatabaseException("No database configuration found");
		}
		let configs = configs["database"];

		for item in configs {
			if (item->name == config) {
				let config = item;
				break;
			}
		}

		if (empty(config)) {
			throw new DatabaseException("No database configuration found");
		}
		
		if (isset(config->type)) {
			let dsn .= config->type . ":";
		} else {
			let dsn .= "mysql:";
		}

		if (empty(config->dbname)) {
			throw new DatabaseException("No database defined in the config");
		}
		let dsn .= "dbname=" . config->dbname . ";";
				
		if (!empty(config->host)) {
			let dsn .= "host=" . config->host . ";";
		} else {
			let dsn .= "host=127.0.0.1;";
		}

		return "<?php\n" .
			"$KBDBBIND = [];\n" .
			"$KBDBSELECT = '';\n" .
			"$KBDBUPDATE = '';\n" .
			"$KBDBTABLE = '';\n" .
			"$KBDBWHERE = '';\n" .
			"$KBDBJOIN = '';\n" .
			"$KBDBSORT = '';\n" .
			"$KBDBLIMIT = '';\n" .
			"$KBDBSET = '';\n" .
			"$KBDBCONN = new \\PDO('" . dsn . "', '" .
			(!empty(config->user) ? config->user : "") . "', '" .
			(!empty(config->password) ? config->password : "") . "');\n?>";
	}

	private function parseRead(args)
	{
		let args = this->args(args);
		return "<?php $KBDBTABLE = \"" . args[0] . "\"; ?>";
	}

	private function parseRightJoin(args)
	{
		let args = this->args(args);
		return "<?php $KBDBJOIN .= \" RIGHT JOIN " . args[0] . "\"; ?>";
	}

	private function parseSelect(args)
	{
		let args = this->args(args);
		return "<?php $KBDBSELECT = \"SELECT " . args[0] . "\"; ?>";
	}

	private function parseSet(args)
	{
		let args = this->args(args);
		return "<?php $KBDBUPDATE = 'UPDATE '; $KBDBSET = \" SET " . args[0] . "\"; ?>";
	}

	private function parseSort(args)
	{
		let args = this->args(args);
		return "<?php $KBDBSORT = \" ORDER BY " . args[0] . "\"; ?>";
	}

	private function parseWhere(args)
	{
		let args = this->args(args);
		return "<?php $KBDBWHERE = \" WHERE " . args[0] . "\"; ?>";
	}
}
