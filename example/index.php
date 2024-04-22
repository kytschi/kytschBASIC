<?php
/*$KBBITMAPWIDTH = 640;
$KBBITMAPHEIGHT = 480;
$KBBITMAPX = 0;
$KBBITMAPY = 0;
$KBBITMAP = imagecreatetruecolor($KBBITMAPWIDTH, $KBBITMAPHEIGHT);
imagealphablending($KBBITMAP, true);
imagesavealpha($KBBITMAP, true);
$KBBKALPHA = imagecolorallocatealpha($KBBITMAP, 0, 0, 0, 127);
imagefill($KBBITMAP, 0, 0, imagecolortransparent($KBBITMAP, $KBBKALPHA));

$KBRGB = [0,0,0,0];
$KBBITMAPRGB = $KBRGB;
$KBCOLOUR = imagecolorallocatealpha($KBBITMAP, $KBRGB[0], $KBRGB[1], $KBRGB[2], $KBRGB[3]);

$KBRGB = [255,0,0,98];
$KBCOLOUR = imagecolorallocatealpha($KBBITMAP, $KBRGB[0], $KBRGB[1], $KBRGB[2], $KBRGB[3]);
imagearc($KBBITMAP, 280, 220, 40, 40, 0, 360, $KBCOLOUR);

$KBIMAGECOPY = imagecreatetruecolor($KBBITMAPWIDTH, $KBBITMAPHEIGHT);
imagealphablending($KBIMAGECOPY, true);
imagesavealpha($KBIMAGECOPY, true);
$KBBKALPHA = imagecolorallocatealpha($KBIMAGECOPY, 0, 0, 0, 127);
imagefill($KBIMAGECOPY, 0, 0, imagecolortransparent($KBIMAGECOPY, $KBBKALPHA));

$KBIMAGEMOVEX = 60;
$KBIMAGEMOVEY = 0;

imagecopymerge($KBIMAGECOPY, $KBBITMAP, $KBIMAGEMOVEX, $KBIMAGEMOVEY, 0, 0, $KBBITMAPWIDTH, $KBBITMAPHEIGHT, 100);
imagecopymerge($KBBITMAP, $KBIMAGECOPY, 0, 0, 0, 0, $KBBITMAPWIDTH, $KBBITMAPHEIGHT, 100);
$KBBKGRND = imagecolorallocatealpha($KBBITMAP, $KBBITMAPRGB[0], $KBBITMAPRGB[1], $KBBITMAPRGB[2], $KBBITMAPRGB[3]);
imagefill($KBBITMAP, $KBBITMAPX, $KBBITMAPY, $KBBKGRND);
ob_start();
imagepng($KBBITMAP);
$KBBITMAP = ob_get_contents();
ob_end_clean();
echo '<img src="data:image/png;base64,' . base64_encode($KBBITMAP) . '">';
die();*/
?>
<?php
(new KytschBASIC\Compiler(__DIR__ . '/../config'))->run();
