/**
 * Compiler
 *
 * @package     KytschBASIC\Compiler
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

	private version = "0.0.7 alpha";

	public function __construct(string config_dir)
	{
		let this->start_time = microtime(true) * 1000;

		if (config_dir) {
			this->loadConfig(config_dir);
		}

		let this->globals["$ROOT_FOLDER"] = getcwd();
		let this->globals["$ROOT_FOLDER_URL"] = _SERVER["REQUEST_SCHEME"] . "://" . _SERVER["HTTP_HOST"];
		let this->globals["$ARCADE_API"] = "kytschBASIC-arcade-internal-api";
		let this->globals["$ARCADE_API_URL"] = this->globals["$ROOT_FOLDER_URL"] . "/" . this->globals["$ARCADE_API"];

		//Session::start(this->config);
	}

	/**
	 * Load the config file.
	 */
	public function loadConfig(string config_dir)
	{
		var err, config, filename;
		var configs = [
			"assets",
			"cache",
			"database",
			"routes",
			"session"
		];

		let this->config = [];

		try {
			for config in configs {
				let filename = config_dir . "/" . config . ".json";
				if (!file_exists(filename)) {
					throw new Exception(
						"config not found, looking for " . config . ".json",
						400,
						this->version
					);
				}

				let this->config[config] = json_decode(file_get_contents(filename));
				if (empty(this->config)) {
					throw new Exception(
						"failed to decode the JSON",
						400,
						this->version
					);
				}
			}
		} catch Exception, err {
		    err->fatal();
		} catch \RuntimeException|\Exception, err {
		    throw new Exception(
				"Failed to load the config, " . err->getMessage(),
				err->getCode(),
				this->version
			);
		}
	}

	public function run()
	{
		if (empty(this->config["routes"])) {
			throw new \Exception("routes not defined in the config");
		}

		var url;
		let url = parse_url(_SERVER["REQUEST_URI"]);
/*
		if (strpos(url["path"], this->globals["$ARCADE_API"]) !== false) {
			var arcade;
			let arcade = new Arcade(this->globals);
			arcade->run();
			return;
		}
*/
		var route, err;
		for route in this->config["routes"] {
			if (!isset(route->url)) {
				(new Exception("router URL not defined in the config"))->fatal();
			}

			if (route->url == url["path"]) {
				var output = (new Parser())->parse(
					getcwd() . "/" . route->template,
					this->config,
					this->globals,
					this->version,
					this->start_time
				);
				
				try {
					let output = "<?php echo '<!DOCTYPE html>';" . output;
					file_put_contents(this->globals["$ROOT_FOLDER"] . "/compiled.php", output);
					echo eval("?>" . output);
				} catch \ParseError, err {
					(new Exception(err->getMessage(), err->getCode()))->fatal();
				} catch \RuntimeException|\Exception, err {
					(new Exception(err->getMessage(), err->getCode()))->fatal();
				}
				return;
			}
		}

		(new Exception("Page not found", 404))->fatal();

		
		echo "<html><body><p>Page not found</p>";
		echo "<hr/>";
		echo "<p>kytschBASIC<br/>";
		echo this->version . "</p></body></html>";
	}
}
