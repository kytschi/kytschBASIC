<?php

/*$string = "onCardClick(test,testing)";
preg_match_all("/\((.*?)\)/", $string, $matches);
var_dump($matches);
die();*/

(new KytschBASIC\Compiler(__DIR__ . '/../config'))->run();
