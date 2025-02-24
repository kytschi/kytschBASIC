# kytschBASIC

A PHP module written in [Zephir](https://zephir-lang.com/en) that will allow you to run a version of BASIC language called kytschBASIC for the web.

## Requirements

* PHP 7.4 to 8.2
* PHP-GD
* PHP-MySQL (Optional)

## Installation

Now open your favourite terminal/console and clone the repo.
```bash
git clone https://github.com/kytschi/kytschBASIC.git

OR

git clone git@github.com:kytschi/kytschBASIC.git
```

Enable the kytschBASIC module. You can copy the sample ini file from the `php` folder in this repo. Remember to do this as root or
a user with administrator permissions.
```bash
cp kytschBASIC/php/kytschBASIC.ini /etc/php/7.4/mods-available/
```

Edit the `kytschBASIC.ini`, then point the extension to the correct location and the desired php version, for example
```
extension=/var/www/kytschbasic/complied/php7.4-kytschbasic.so
```

And don't forget to restart the PHP service.

Next setup an index.php on your webserver of choice and tell it to load the kytschBASIC compiler.
```php
<?php
(new KytschBASIC\Compiler(__DIR__ . '/../config'))->run();
```

NOTICE we are loading in the configuration file. See configuration for more information on how to setup the configuration file.

For example website checkout the `example` folder in this repo.

## Configuration

kytschBASIC configuration is handled via a JSON config file. From there you can define the database connection, the routes, etc.
[kytschBASIC example configs](https://github.com/kytschi/kytschBASIC/tree/master/config)

### Database

The configuration for the database connection if needed. You can define more than one.
```json
[
	{
		"name":"kytschBASIC", 		<-- Name of the connection
		"type": "mysql", 			<-- Connection type
		"host": "127.0.0.1",		<-- Host IP
		"port": 3306,				<-- Host port
		"dbname": "kytschBASIC",	<-- Name of the database
		"user": "user",				<-- Username that has access
		"password": "password"		<-- Password of the user
	}
]
```

### Routes
The routes allow you to define what kytschBASIC template is to be loaded for a specific URL or route.
```json
[
	{
		"url": "/",						<-- The URL/route that corresponds to the template.
		"template": "project/index.kb"	<-- The kytschBASIC template. Be sure to include its folder if its in one.
	},
	{
		"url": "/about",
		"template": "project/about.kb"
	},
	{
		"url": "/installation",
		"template": "project/installation.kb"
	},
	{
		"url": "/news",
		"template": "project/news.kb"
	}
]
```

## Building from source

First thing you will need is to install [Zephir](https://docs.zephir-lang.com/0.12/en/installation)

Now to build the kytschBASIC PHP module run the following assuming `kytschBASIC` is the root folder for the source code.
```bash
cd kytschBASIC/kytschbasic
zephir build
```

## More information
For more information and a to view the available command set please visit [https://kytschbasic.org](https://kytschbasic.org)
