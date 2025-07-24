/**
 * Compiler
 *
 * @package     KytschBASIC\Compiler
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.15 alpha
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

class Compiler
{
	/**
	 * Var for holding the config object from the config JSON.
	 */
	private config;

	private globals = [];

	private start_time;
	
	private version = "0.0.15 alpha";

	private vendor_folder = "../kytschbasic/vendor";

	private cli;

	public function __construct(string config_dir, bool cli = false)
	{
		define("START_TIME", microtime(true) * 1000);

		let this->cli = cli;

		if (config_dir) {
			this->loadConfig(config_dir);
		}

		//Surpress the errors and let kytschBASIC take over.
		ini_set("display_errors", "0");
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
		
		// Include the vendor folder for external libs.
		require_once this->vendor_folder . "/autoload.php";

		/*let this->globals["_ARCADE"] = "kytschBASIC-arcade-internal-api",
		let this->globals["_AURL"] = this->globals["_RURL"] . "/" . this->globals["_ARCADE"];*/

		//Session::start(this->config);
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
		var err, output = "";

		var parsed = (new Parser())->parse(constant("_ROOT") . "/" . route->template);
		
		try {
			let output = output . "<!DOCTYPE html>";
			let output = output . parsed;
			file_put_contents(constant("_ROOT") . "/compiled.php", output);
			require (constant("_ROOT") . "/compiled.php");
		} catch \RuntimeException|\Exception, err {
			(new Exception(err->getMessage(), err->getCode()))->fatal();
		}
		return;
	}

	public function run()
	{
		var config, url_vars = [];
		let config = constant("CONFIG");

		if (empty(config["routes"])) {
			throw new \Exception("routes not defined in the config");
		}

		var url, fallback;
		let url = parse_url(_SERVER["REQUEST_URI"]);
		let fallback = null;

		if (isset(url["path"])) {
			var route, key, end, matches, path, splits;

			let path = url["path"];
			
			for route in config["routes"] {
				if (!isset(route->url)) {
					(new Exception("route URL not defined in the config"))->fatal();
				}
				if (!isset(route->template)) {
					(new Exception("route template not defined in the config"))->fatal();
				}

				// Fallback url, catch all basically.
				if (route->url == "*") {
					let fallback = route;
					continue;					
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
					define("_UVARS", url_vars);
					return this->compile(route);
				}
			}
		}

		if (!empty(fallback)) {
			return this->compile(fallback);
		}

		(new Exception("Page not found", 404))->fatal();
	}
}
