<?php
	foreach(glob('conf/*') as $v) {
		$files[] = str_replace(['conf/', '.ini'], '' , $v);
	}
	file_put_contents('all.json', json_encode($files));
	sleep(1111);
?>