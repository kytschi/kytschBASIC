/**
 * Compiler
 *
 * @package     KytschBASIC\Compiler
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.17 alpha
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
namespace KytschBASIC;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Parser;
use KytschBASIC\Parsers\Core\Session;

class Compiler
{
	/**
	 * Var for holding the config object from the config JSON.
	 */
	private config;

	private globals = [];

	private start_time;
	
	private version = "0.0.17 alpha";

	private cli;

	public function __construct(string config_dir, bool cli = false)
	{
		define("START_TIME", microtime(true) * 1000);

		let this->cli = cli;

		if (config_dir) {
			this->loadConfig(config_dir);
		}

		// Surpress the errors and let kytschBASIC take over.
		ini_set("display_errors", "0");
		//error_reporting(E_ERROR | E_PARSE);
		register_shutdown_function("KytschBASIC\\Compiler::shutdownError", cli);

		define("VERSION", this->version);

		if (!cli) {
			var url;
			let url = parse_url(_SERVER["REQUEST_URI"]);

			define("_ROOT", getcwd());
			define("_RURL", _SERVER["REQUEST_SCHEME"] . "://" . _SERVER["HTTP_HOST"]);
			define("_URL", _SERVER["REQUEST_URI"]);
			define("_PATH", url["path"]);
		}
		
		// Start the session
		Session::start();
	}

	public static function shutdownError(cli)
	{
		var err;
		let err = error_get_last();
		if (err) {
			(
				new Exception(
					err["message"],
					500,
					(cli ? false : true)
				)
			)->fatal();
			die();
		}
	}

	/*
	 * Load the config file.
	 */
	public function loadConfig(string config_dir)
	{
		var item, config = [], filename;
		var configs = [
			"assets",
			"cache",
			"database",
			"routes",
			"security",
			"session",
			"websocket"
		];

		try {
			for item in configs {
				let filename = config_dir . "/" . item . ".json";
				if (!file_exists(filename)) {
					throw new Exception(
						"config not found, looking for " . item . ".json",
						400,
						(this->cli ? false : true)
					);
				}

				let config[item] = json_decode(file_get_contents(filename));
				if (empty(config[item])) {
					throw new Exception(
						"failed to decode the JSON",
						400,
						(this->cli ? false : true)
					);
				}
			}

			define("CONFIG", config);
		} catch Exception, item {
		    item->fatal();
		} catch \RuntimeException|\Exception, item {
		    throw new Exception(
				"Failed to load the config, " . item->getMessage(),
				item->getCode(),
				(this->cli ? false : true)
			);
		}
	}

	private function compile(route)
	{
		var err;

		try {
			var parsed = (new Parser())->parse(constant("_ROOT") . "/" . route->template);
			file_put_contents(constant("_ROOT") . "/compiled.php", "<!DOCTYPE html>\n" . parsed);
			require_once(constant("_ROOT") . "/compiled.php");
			return "";
		} catch Exception, err {
			err->fatal(constant("_ROOT") . "/" . route->template);
		} catch \RuntimeException | \Exception | \ParserError, err {
			(new Exception(
					err->getMessage(),
					err->getCode(),
					true,
					err->getLineNo()
				)
			)->fatal(constant("_ROOT") . "/" . route->template);
		}
	}

	public function run()
	{
		var config, url_vars = [], user_session_var = "user", url, fallback = null;

		let config = constant("CONFIG");

		if (empty(config["routes"])) {
			throw new \Exception("routes not defined in the config");
		}

		if (!empty(config["session"])) {
			if (isset(config["session"]->user_session_var) && !empty(config["session"]->user_session_var)) {
				let user_session_var = config["session"]->user_session_var;
			}
		}

		let url = parse_url(_SERVER["REQUEST_URI"]);
				
		if (isset(url["path"])) {
			var route, key, end, matches, path, splits, login_route, primary_route;

			// Find the primary and login route first if there is one.
			for route in config["routes"] {
				if (empty(route)) {
					continue;
				} elseif (isset(route->login) && !empty(route->login)) {
					let login_route = route;
					continue;
				} elseif (isset(route->primary) && !empty(route->primary)) {
					let primary_route = route;
					continue;
				}
				
				if (route->url == "*") {
					// Fallback url, catch all basically.
					let fallback = route;
					continue;
				}
			}

			for route in config["routes"] {
				if (empty(route)) {
					continue;
				}

				let path = url["path"];
				let url_vars = [];

				if (!isset(route->url)) {
					(new Exception("route URL not defined in the config"))->fatal();
				}
				if (!isset(route->template)) {
					(new Exception("route template not defined in the config"))->fatal();
				}

				// Check to see if the url has any dynamic vars in it.
				if preg_match_all("/\\{([^}]*)\\}/", route->url, matches, PREG_OFFSET_CAPTURE) {
					let splits = preg_split("#/+#", trim(path, "/"), -1, PREG_SPLIT_NO_EMPTY | PREG_SPLIT_OFFSET_CAPTURE);
					let key = count(matches[0]) - 1;
					let end = count(splits) - 1;
					while (key != -1) {
						let path = str_replace(
							splits[end][0],
							matches[0][key][0],
							path,
							1
						);

						let url_vars[matches[1][key][0]] = splits[end][0];

						let key -= 1;
						let end -= 1;
					}
				}
				
				if (route->url == path) {
					let fallback = null;

					/*
					 * If there is a login and a primary route, kick the user to it.
					 */
					if (
						!empty(login_route) &&
						login_route->url == path &&
						Session::read(user_session_var) &&
						primary_route
					) {
						header("Location: " . primary_route->url);
						die();
					}

					/*
					 * Check to see if the route is a secure one. If it is, look for a valid session user.
					 * If there is not then kick the user to the login defined in the routes.json.
					 */
					if (isset(route->secure) && !empty(route->secure) && !empty(login_route)) {
						if (empty(Session::read(user_session_var)) && login_route->url != path) {
							header("Location: " . login_route->url);
							die();
						}
					}

					define("_UVARS", url_vars);
					return this->compile(route);
				}
			}

			if (fallback) {
				return this->compile(fallback);
			}
		}

		(new Exception("Page not found", 404))->fatal();
	}
}
