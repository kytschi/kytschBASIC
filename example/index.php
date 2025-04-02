<?php
/*$line = '"/kytschi/imgs/cards/" + suit$ + "_" + face$ + ".svg"';
$splits = preg_replace("/\+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", ".", $line);
var_dump($splits);
die();*/
(new KytschBASIC\Compiler(__DIR__ . '/../config'))->run();
