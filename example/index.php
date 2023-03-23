<?php

use KytschBASIC\Compiler;

try {
    (new Compiler(__DIR__ . '/../config'))->run();
} catch (\Exception $err) {
    (new KytschException($err->getMessage()))->fatal();
}
