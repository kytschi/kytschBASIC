<?php

use KytschBASIC\Compiler;
use KytschBASIC\Exceptions\Exception as KytschException;

try {
    (new Compiler(__DIR__ . '/../config'))->run();
} catch (\Exception $err) {
    (new KytschException($err->getMessage()))->fatal();
}
