/**
 * Database parser
 *
 * @package     KytschBASIC\Parsers\Core\Database
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2022 Mike Welsh
 * @link 		https://kytschbasic.org
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
namespace KytschBASIC\Parsers\Core;

use KytschBASIC\Exceptions\DatabaseException;
use KytschBASIC\Parsers\Core\Command;

class Database extends Command
{
	/*private function close(array globals = [])
	{
		if (empty(this->database)) {
			throw new DatabaseException("no database selected to read");
		}

		var dsn = "", output;

		if (isset(this->database_config->type)) {
			let dsn .= this->database_config->type . ":";
		} else {
			let dsn .= "mysql:";
		}

		if (empty(this->database_config->dbname)) {
			throw new DatabaseException("no database defined in the config");
		}
		let dsn .= "dbname=" . this->database_config->dbname . ";";
				
		if (!empty(this->database_config->host)) {
			let dsn .= "host=" . this->database_config->host . ";";
		} else {
			let dsn .= "host=127.0.0.1;";
		}
		
		let output = "<?php try{$connection = new \\PDO('" . dsn . "','" . (!empty(this->database_config->user) ? this->database_config->user : "") . "','" . (!empty(this->database_config->password) ? this->database_config->password : "") . "');";
		let output = output . "$statement = $connection->prepare(\"" . this->parseGlobals(globals, str_replace("\"", "'", this->data_sql)) . "\");";
		let output = output . "$statement->execute((array)json_decode('" . json_encode(this->data_bind) . "'));";

		return output . "$" . str_replace(["$", "%", "#", "&"], "", this->data_var) . "=$statement->fetchAll();} catch(\\PDOException $err) {new KytschBASIC\\Exceptions\\Exception($err->getMessage(), 500);}?>";
	}*/

	public function parse(string command, string args)
	{
		if (command == "DOPEN") {
			return this->parseDOpen(args);
		} elseif (command == "DFETCH") {
			return this->parseDFetch(args);
		} elseif (command == "DREAD") {
			return this->parseDRead(args);
		} elseif (command == "DSELECT") {
			return this->parseDSelect(args);
		} elseif (command == "DWHERE") {
			return this->parseDWhere(args);
		} elseif (command == "DSORT") {
			return this->parseDSort(args);
		}
		/*var err, controller;
		let controller = new Args();

		try {
			elseif (command == "DBIND") {
				var args, arg, splits;
				let args = this->parseArgs("DBIND", line);
				if (empty(this->database)) {
					throw new DatabaseException("no database selected to read");
				}

				for arg in args {
					let splits = explode("=", arg);
					if (!empty(splits[0]) && !empty(splits[0])) {
						if (!this->isVar(splits[1])) {
							let this->data_bind[splits[0]] = splits[1];
						} else {
							let this->data_bind[splits[0]] = "'." . this->parseVar(splits[1]) . ".'";
						}
					}
				}
				
				return true;
			} elseif (command == "DJOIN") {
				if (empty(this->database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DJOIN ", "", line);
				let this->data_sql = this->data_sql . " JOIN " . this->cleanArg(line, false);

				return true;
			} elseif (command == "DLJOIN") {
				if (empty(this->database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DLJOIN ", "", line);
				let this->data_sql = this->data_sql . " LEFT JOIN " . this->cleanArg(line, false);

				return true;
			} elseif (command == "DRJOIN") {
				if (empty(this->database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DRJOIN ", "", line);
				let this->data_sql = this->data_sql . " RIGHT JOIN " . this->cleanArg(line, false);

				return true;
			} elseif (command == "DLIMIT") {
				if (empty(this->database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DLIMIT ", "", line);
				let this->data_sql = this->data_sql . " LIMIT " . intval(this->cleanArg(line, false));

				return true;
			} elseif (command == "DSET") {
				if (empty(this->database)) {
					throw new DatabaseException("no database selected to set to data with");
				}

				let line = str_replace("DSET ", "", line);
				let this->data_sql = "INSERT INTO " . this->database . " SET " . controller->clean(line, config);

				return true;
			}

			return null;
		} catch DatabaseException, err {
		    err->fatal();
		} catch \RuntimeException|\Exception, err {
		    throw new \Exception("Failed to connect to the database (" . this->database_config->dbname . ")" . ", " . err->getMessage());
		}*/
	}

	private function parseDOpen(args)
	{
		var config, configs, dsn = "", item;
		let configs = constant("CONFIG");

		let args = this->args(args);
		let config = this->setArg(args[0]);
		
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

		return "<?php $KBDBBIND=[]; $KBDBCONN = new \\PDO('" . dsn . "','" .
			(!empty(config->user) ? config->user : "") . "','" .
			(!empty(config->password) ? config->password : "") . "');?>";
	}

	private function parseDFetch(args)
	{
		let args = this->args(args);
		return "<?php
		$KBDBSTATEMENT = $KBDBCONN->prepare($KBDBSELECT . $KBDBTABLE . $KBDBWHERE . $KBDBSORT);
		$KBDBSTATEMENT->execute($KBDBBIND);" .
		this->setArg(args[0]) . "=$KBDBSTATEMENT->fetchAll();?>";
	}

	private function parseDRead(args)
	{
		let args = this->args(args);
		return "<?php $KBDBTABLE=\" FROM " . this->setArg(args[0]) . "\"; ?>";
	}

	private function parseDSelect(args)
	{
		let args = this->args(args);
		return "<?php $KBDBSELECT=\"SELECT " . this->setArg(args[0]) . "\"; ?>";
	}

	private function parseDSort(args)
	{
		let args = this->args(args);
		return "<?php $KBDBSORT=\" ORDER BY " . this->setArg(args[0]) . "\"; ?>";
	}

	private function parseDWhere(args)
	{
		let args = this->args(args);
		return "<?php $KBDBWHERE=\" WHERE " . this->setArg(args[0]) . "\"; ?>";
	}
}
