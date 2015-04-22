<?php
	foreach(glob('conf/*') as $v) {
		file_put_contents($v, iconv('windows-1251', 'UTF-8', file_get_contents($v)));
	}
	
	sleep(1111);
?>