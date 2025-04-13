/**
 * Database parser
 *
 * @package     KytschBASIC\Parsers\Core\Database
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.2
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
use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Database extends Command
{
	private function dbClean(arg)
	{
		let arg = str_replace("[", "(", trim(arg, "\""));
		return str_replace("]", ")", arg);
	}

	public function parse(string line, string command, array args)
	{
		var err;

		try {
			switch (command) {
				case "DOPEN":
					return this->parseOpen(args);
				case "DFETCH":
					return this->parseFetch(args);
				case "DREAD":
					return this->parseRead(args);
				case "DSELECT":
					return this->parseSelect(args);
				case "DWHERE":
					return this->parseWhere(args);
				case "DSORT":
					return this->parseSort(args);
				case "DBIND":
					return this->parseBind(args);
				case "DJOIN":
					return this->parseJoin(args);
				case "DLJOIN":
					return this->parseLeftJoin(args);
				case "DRJOIN":
					return this->parseRightJoin(args);
				case "DLIMIT":
					return this->parseLimit(args);
				case "DSET":
					return this->parseSet(args);
			 	case "DEXEC":
					return this->parseExecute();
				case "END DATA":
					return "";
				default:
					return null;
			}
		} catch DatabaseException, err {
		    err->fatal();
		} catch \RuntimeException|\Exception, err {
		    throw new \Exception("Database error, " . err->getMessage());
		}
	}

	private function parseBind(args)
	{
		var arg, output = "<?php ", splits;
		
		if (count(args) < 1) {
			throw new Exception("Invalid DBIND");
		}

		for arg in args {
			let splits = this->equalsSplit(arg);
			if (count(splits) <= 1) {
				throw new Exception("Invalid DBIND");
			}
			let output .= "$KBDBBIND['" . trim(splits[0]) . "'] = " . trim(splits[1]) . ";";
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
		if (!count(args)) {
			throw new Exception("Invalid DFETCH");
		}

		return this->parseExecute() . "\n<?php " . str_replace(["\"", "{", "}"], "", args[0]) . " = $KBDBSTATEMENT->fetchAll(); ?>";
	}

	private function parseJoin(args)
	{
		if (!count(args)) {
			throw new Exception("Invalid DJOIN");
		}

		return "<?php $KBDBJOIN .= \" JOIN " . this->dbClean(args[0]) . "\"; ?>";
	}

	private function parseLeftJoin(args)
	{
		if (!count(args)) {
			throw new Exception("Invalid DLJOIN");
		}

		return "<?php $KBDBJOIN .= \" LEFT JOIN " . this->dbClean(args[0]) . "\"; ?>";
	}

	private function parseLimit(args)
	{
		if (!count(args)) {
			throw new Exception("Invalid DLIMIT");
		}

		return "<?php $KBDBLIMIT = \" LIMIT " . this->dbClean(args[0]) . "\"; ?>";
	}

	private function parseOpen(args)
	{
		var config, configs, dsn = "", item;
		let configs = constant("CONFIG");

		if (!count(args)) {
			throw new Exception("Invalid DOPEN");
		}

		let config = trim(args[0], "\"");
				
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
		if (!count(args)) {
			throw new Exception("Invalid DREAD");
		}

		return "<?php $KBDBTABLE = " . args[0] . "; ?>";
	}

	private function parseRightJoin(args)
	{
		if (!count(args)) {
			throw new Exception("Invalid DRJOIN");
		}

		return "<?php $KBDBJOIN .= \" RIGHT JOIN " . this->dbClean(args[0]) . "\"; ?>";
	}

	private function parseSelect(args)
	{
		if (!count(args)) {
			throw new Exception("Invalid DSELECT");
		}

		return "<?php $KBDBSELECT = \"SELECT " . this->dbClean(args[0]) . "\"; ?>";
	}

	private function parseSet(args)
	{
		if (!count(args)) {
			throw new Exception("Invalid DSET");
		}

		return "<?php $KBDBUPDATE = 'UPDATE '; $KBDBSET = \" SET " . this->dbClean(args[0]) . "\"; ?>";
	}

	private function parseSort(args)
	{
		if (!count(args)) {
			throw new Exception("Invalid DSORT");
		}

		return "<?php $KBDBSORT = \" ORDER BY " . this->dbClean(args[0]) . "\"; ?>";
	}

	private function parseWhere(args)
	{
		if (!count(args)) {
			throw new Exception("Invalid DWHERE");
		}

		return "<?php $KBDBWHERE = \" WHERE " . this->dbClean(args[0]) . "\"; ?>";
	}
}
