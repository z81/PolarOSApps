<?php


foreach(glob('./gif/*.png') as $f) {
	$output = pathinfo($f);
	$output = realpath("./svg").$output['filename'].".svg";
	echo exec("\"potrace-1.11.win64/potrace.exe\" -o \"$output\" \"" . realpath($f). "\" --svg");
}

exit;
foreach(glob('./icon/*.png') as $f) {
	$img = imagecreatefrompng($f);

	$background = imagecolorallocate($img, 0, 0, 0);

	imagecolortransparent($img, $background);

	imagepng($img, str_replace('./icon', './gif', $f));

}