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
	private static data;

	/**
	 * The var name for the data at the time.
	 */
	private static data_var = "";

	/**
	 * If the DATA line is being processed.
	 */
	private static data_line = false;

	/**
	 * Holds the DATA SQL that'll get built from parsing.
	 */
	private static data_sql = "";

	/**
	 * The database to connect to based on the OPEN line.
	 */
	private static database = "";

	/**
	 * The database config.
	 */
	private static database_config = null;

	private static function close()
	{
		if (empty(self::database)) {
			throw new DatabaseException("no database selected to read");
		}

		var dsn = "", output;

		if (isset(self::database_config->type)) {
			let dsn .= self::database_config->type . ":";
		} else {
			let dsn .= "mysql:";
		}

		if (empty(self::database_config->dbname)) {
			throw new DatabaseException("no database defined in the config");
		}
		let dsn .= "dbname=" . self::database_config->dbname . ";";
				
		if (!empty(self::database_config->host)) {
			let dsn .= "host=" . self::database_config->host . ";";
		} else {
			let dsn .= "host=127.0.0.1;";
		}
		
		let output = "<?php $connection = new \\PDO('" . dsn . "','" . (!empty(self::database_config->user) ? self::database_config->user : "") . "','" . (!empty(self::database_config->password) ? self::database_config->password : "") . "');";
		let output = output . "$statement = $connection->prepare(\"" . str_replace("\"", "'", self::data_sql) . "\");";
		let output = output . "$statement->execute();";

		let self::data_line = false;
		return output . "$" . str_replace(["$", "%", "#", "&"], "", self::data_var) . "=$statement->fetchAll();?>";
	}

	public static function parse(
		string line,
		event_manager = null,
		array globals = [],
		var config = null
	) {
		var err;

		try {
			if (self::match(line, "DATA CLOSE")) {
				return self::close();
			} elseif (self::match(line, "DATA") && !self::match(line, "DATA CLOSE")) {
				var args = self::parseArgs("DATA", line);

				if (empty(args[0])) {
					throw new DatabaseException("DATA variable name missing");
				}

				let self::data_var = trim(args[0]);
				let self::data_line = true;
				return true;
			} elseif (self::match(line, "DOPEN")) {
				var open, db_config;
				var args = self::parseArgs("DOPEN", line);
				if (isset(args[0])) {
					let open = self::cleanArg(args[0]);
				}

				if (empty(config["database"])) {
					throw new DatabaseException("db settings not found in the config");
				}

				for db_config in config["database"] {
					if (db_config->name == open) {
						let self::database_config = db_config;
						break;
					}
				}

				if (empty(self::database_config)) {
					throw new DatabaseException("no db settings not found in the config for " . open);
				}

				return true;
			} elseif (self::match(line, "DREAD")) {
				var args = self::parseArgs("DREAD", line);

				if (isset(args[0])) {
					let self::database = self::cleanArg(args[0]);
				}

				if (empty(self::database)) {
					throw new DatabaseException("no database selected to read");
				}
				return true;
			} elseif (self::match(line, "DSELECT")) {
				if (empty(self::database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DSELECT ", "", line);
				let self::data_sql = "SELECT " . self::cleanArg(line) . " FROM " . self::database;
				
				return true;
			} elseif (self::match(line, "DWHERE")) {
				if (empty(self::database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DWHERE ", "", line);
				let self::data_sql = str_replace("INSERT INTO", "UPDATE", self::data_sql) .  " WHERE " . self::cleanArg(line);

				return true;
			} elseif (self::match(line, "DSORT")) {
				if (empty(self::database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DSORT ", "", line);
				let self::data_sql = self::data_sql . " ORDER BY " . self::cleanArg(line);

				return true;
			} elseif (self::match(line, "DLIMIT")) {
				if (empty(self::database)) {
					throw new DatabaseException("no database selected to read");
				}

				let line = str_replace("DLIMIT ", "", line);
				let self::data_sql = self::data_sql . " LIMIT " . intval(self::cleanArg(line));

				return true;
			} elseif (self::match(line, "DSET")) {
				if (empty(self::database)) {
					throw new DatabaseException("no database selected to set to data with");
				}

				let line = str_replace("DSET ", "", line);
				let self::data_sql = "INSERT INTO " . self::database . " SET " . Args::clean(line, config);

				return true;
			} /*elseif (self::data_line) {
				 //Building the SQL for the data connection instead of parsing.
				return true;
			}*/

			return null;
		} catch DatabaseException, err {
		    err->fatal();
		} catch \RuntimeException|\Exception, err {
		    throw new \Exception("Failed to connect to the database (" . self::database_config->dbname . ")" . ", " . err->getMessage());
		}
	}
}
