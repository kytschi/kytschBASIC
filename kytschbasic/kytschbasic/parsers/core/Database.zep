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

use KytschBASIC\Parsers\Core\Command;
use KytschBASIC\Parsers\Core\Session;

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
			throw new \Exception("no database selected to read");
		}

		var dsn = "", connection, statement;

		if (isset(self::database_config->type)) {
			let dsn .= self::database_config->type . ":";
		} else {
			let dsn .= "mysql:";
		}

		if (empty(self::database_config->dbname)) {
			throw new \Exception("no database defined in the config");
		}
		let dsn .= "dbname=" . self::database_config->dbname . ";";
				
		if (!empty(self::database_config->host)) {
			let dsn .= "host=" . self::database_config->host . ";";
		} else {
			let dsn .= "host=127.0.0.1;";
		}

		let connection = new \PDO(
			dsn,
			!empty(self::database_config->user) ? self::database_config->user : "",
			!empty(self::database_config->password) ? self::database_config->password : ""
		);

		let statement = connection->prepare(self::data_sql);
		statement->execute();

		Session::write(self::data_var, statement->fetchAll());
		let self::data_line = false;

		return true;
	}

	public static function parse(
		string line,
		event_manager = null,
		array globals = [],
		config
	) {
		var err;

		try {
			if (self::match(line, "DATA CLOSE")) {
				return self::close();
			} elseif (self::match(line, "DATA")) {
				var args = self::parseArgs("DATA", line);

				if (empty(args[0])) {
					throw new \Exception("DATA variable name missing");
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
					throw new \Exception("db settings not found in the config");
				}

				for db_config in config["database"] {
					if (db_config->name == open) {
						let self::database_config = db_config;
						break;
					}
				}

				if (empty(self::database_config)) {
					throw new \Exception("no db settings not found in the config for " . open);
				}

				return true;
			} elseif (self::match(line, "DREAD")) {
				var args = self::parseArgs("DREAD", line);

				if (isset(args[0])) {
					let self::database = self::cleanArg(args[0]);
				}

				if (empty(self::database)) {
					throw new \Exception("no database selected to read");
				}
				return true;
			} elseif (self::match(line, "DSELECT")) {
				if (empty(self::database)) {
					throw new \Exception("no database selected to read");
				}

				var args = self::parseArgs("DSELECT", line);
				if (isset(args[0])) {
					let self::data_sql = "SELECT " . self::cleanArg(args[0]) . " FROM " . self::database;
				}
				return true;
			} elseif (self::match(line, "DWHERE")) {
				if (empty(self::database)) {
					throw new \Exception("no database selected to read");
				}

				var args = self::parseArgs("DWHERE", line);
				if (isset(args[0])) {
					let self::data_sql = self::data_sql .  " WHERE " . self::cleanArg(args[0]);
				}

				return true;
			} elseif (self::match(line, "DSORT")) {
				if (empty(self::database)) {
					throw new \Exception("no database selected to read");
				}

				var args = self::parseArgs("DSORT", line);
				if (isset(args[0])) {
					let self::data_sql = self::data_sql . " ORDER BY " . self::cleanArg(args[0]);
				}

				return true;
			} elseif (self::data_line) {
				 //Building the SQL for the data connection instead of parsing.
				return true;
			}

			return false;
		} catch \RuntimeException|\Exception, err {
			var message;

			let message = "Failed to connect to the database (" .
				self::database_config->dbname . ")" .
				", " . err->getMessage();

			if (err->getMessage() == "invalid data source name") {
				let message = message . " (" . self::database . ")";
			}

		    throw new \Exception(message);
		}
	}
}
