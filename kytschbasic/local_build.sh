#!/bin/bash
version="8.2"
printf " Building kytschBASIC for PHP $version\n"
./vendor/bin/zephir fullclean
./vendor/bin/zephir build
cp ext/modules/kytschbasic.so ../compiled/php$version-kytschbasic.so
sudo service php$version-fpm restart
echo " Build complete"