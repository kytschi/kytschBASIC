<?php
/*$line = 'DEF card$="/kytschi/imgs/cards/12_clubs.svg"';
$splits = preg_split("/([+\-\/])(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)/", $line, 0, 2);
var_dump($splits);
die();*/
(new KytschBASIC\Compiler(__DIR__ . '/../config'))->run();
