/**
 * Database parser
 *
 * @package     KytschBASIC\Parsers\Core\Database
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
namespace KytschBASIC\Parsers\Core;

use KytschBASIC\Exceptions\DatabaseException;
use KytschBASIC\Parsers\Core\Command;

class Database extends Command
{
	/**
	 * Hold the any data triggered from a DATA connection with the database.
	 */
	private data;

	/**
	 * The var name for the data at the time.
	 */
	private data_var = "";

	/**
	 * If the DATA binds.
	 */
	private data_bind = [];

	/**
	 * Holds the DATA SQL that'll get built from parsing.
	 */
	private data_sql = "";

	/**
	 * The database to connect to based on the OPEN line.
	 */
	private database = "";

	/**
	 * The database config.
	 */
	private database_config = null;

	private function close(array globals = [])
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
		
		let output = "<?php $connection = new \\PDO('" . dsn . "','" . (!empty(this->database_config->user) ? this->database_config->user : "") . "','" . (!empty(this->database_config->password) ? this->database_config->password : "") . "');";
		let output = output . "$statement = $connection->prepare(\"" . this->parseGlobals(globals, str_replace("\"", "'", this->data_sql)) . "\");";
		let output = output . "$statement->execute((array)json_decode('" . json_encode(this->data_bind) . "'));";

		return output . "$" . str_replace(["$", "%", "#", "&"], "", this->data_var) . "=$statement->fetchAll();?>";
	}

	public function parse(
		string line,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		var err, controller;
		let controller = new Args();

		try {
			if (this->match(line, "DATA CLOSE")) {
				return this->close(globals);
			} elseif (this->match(line, "DATA") && !this->match(line, "DATA CLOSE")) {
				var args = this->parseArgs("DATA", line);

				if (empty(args[0])) {
					throw new DatabaseException("DATA variable name missing");
				}

				let this->data_var = trim(args[0]);
				return true;
			} elseif (this->match(line, "DOPEN")) {
				var open, db_config;
				var args = this->parseArgs("DOPEN", line);
				if (isset(args[0])) {
					let open = this->cleanArg(args[0], false);
				}

				if (empty(config["database"])) {
					throw new DatabaseException("db settings not found in the config");
				}

				for db_config in config["database"] {
					if (db_config->name == open) {
						let this->database_config = db_config;
						break;
					}
				}

				if (empty(this->database_config)) {
					throw new DatabaseException("no db settings not found in the config for " . open);
				}

				return true;
			} elseif (this->match(line, "DREAD")) {
				var args = this->parseArgs("DREAD", line);

				if (isset(args[0])) {
					let this->database = this->cleanArg(args[0], false);
				}

				if (empty(this->database)) {
					throw new DatabaseException("no database selected to read");
				}
				return true;
			} elseif (this->match(line, "DBIND")) {
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
			} elseif (this->match(line, "DSELECT")) {
				if (empty(this->database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DSELECT ", "", line);
				let this->data_sql = "SELECT " . this->cleanArg(line, false) . " FROM " . this->database;
				
				return true;
			} elseif (this->match(line, "DWHERE")) {
				if (empty(this->database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DWHERE ", "", line);
				let this->data_sql = str_replace("INSERT INTO", "UPDATE", this->data_sql) .
					" WHERE " .
					this->cleanArg(line, false);

				return true;
			} elseif (this->match(line, "DSORT")) {
				if (empty(this->database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DSORT ", "", line);
				let this->data_sql = this->data_sql . " ORDER BY " . this->cleanArg(line, false);

				return true;
			} elseif (this->match(line, "DJOIN")) {
				if (empty(this->database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DJOIN ", "", line);
				let this->data_sql = this->data_sql . " JOIN " . this->cleanArg(line, false);

				return true;
			} elseif (this->match(line, "DLJOIN")) {
				if (empty(this->database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DLJOIN ", "", line);
				let this->data_sql = this->data_sql . " LEFT JOIN " . this->cleanArg(line, false);

				return true;
			} elseif (this->match(line, "DRJOIN")) {
				if (empty(this->database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DRJOIN ", "", line);
				let this->data_sql = this->data_sql . " RIGHT JOIN " . this->cleanArg(line, false);

				return true;
			} elseif (this->match(line, "DLIMIT")) {
				if (empty(this->database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DLIMIT ", "", line);
				let this->data_sql = this->data_sql . " LIMIT " . intval(this->cleanArg(line, false));

				return true;
			} elseif (this->match(line, "DSET")) {
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
		}
	}
}
