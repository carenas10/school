<?php
require '../Path.php';
require Path::php().'Log.php';
foreach($_SERVER as $key => $value) {
	Log::logMsg($key);
	Log::logMsg($value);
}
if(isset($_GET['name']) && isset($_GET['type'])) {
	$path = Path::media().$_GET['name'];
	if(file_exists($path)) {
		if($_GET['type'] == 'image') {
			$filesize = sprintf("%u", filesize($path));
			header('Content-type: image/jpeg');
			header("Content-Length: $filesize");
			readfile($path);
		} else if($_GET['type'] == 'audio') {
			stream($path, 'audio/mpeg');
		} else if($_GET['type'] == 'video') {
			stream($path, 'video/mp4');
		} else {
			throw new InvalidStateException('unrecognized media type');
		}
	} else {
		header("HTTP/1.1 404 Not Found");
        exit;
    }
}

function stream($file, $content_type = 'application/octet-stream') {
    // Get file size
    $filesize = sprintf("%u", filesize($file));

    // Handle 'Range' header
    if(isset($_SERVER['HTTP_RANGE'])){
        $range = $_SERVER['HTTP_RANGE'];
    } else $range = FALSE;

    // Is range
    if($range){
        $partial = true;
        list($param, $range) = explode('=',$range);
        // Bad request - range unit is not 'bytes'
        if(strtolower(trim($param)) != 'bytes'){ 
            header("HTTP/1.1 400 Invalid Request");
            exit;
        }
        // Get range values
        $range = explode(',',$range);
        // Take only $range[0], ignore other subranges
        $range = explode('-',$range[0]); 
        // Deal with range values
        if($range[0] === ''){
            $end = $filesize - 1;
            $start = $filesize - intval($range[1]);
            if($start < 0)
            	$start = 0;
        } else if($range[1] === '') {
            $start = intval($range[0]);
            $end = $filesize - 1;
        } else { 
            // Both numbers present, return specific range
            $start = intval($range[0]);
            $end = intval($range[1]);
            if($start > $end)
            	$partial = false;
            if($start >= $filesize)
            	$partial = false;
            if($end >= $filesize)
            	$end = $filesize -1;
        }
        $length = $end - $start + 1;
    }
    // No range requested
    else $partial = false; 
    $partial = false;

    // Send standard headers
    if(!$partial) {
    	header('HTTP/1.1 200 OK');
    } else {
    	header('HTTP/1.1 206 Partial Content');
    }
    header("Content-Type: $content_type");
    header("Content-Length: $filesize");
    header('Accept-Ranges: bytes');
    // send extra headers for range handling...
    if($partial) {
        header("Content-Range: bytes $start-$end/$filesize");
        if(!$fp = fopen($file, 'rb')) {
            header("HTTP/1.1 500 Internal Server Error");
            exit;
        }
        if($start) fseek($fp, $start);
        while($length){
            set_time_limit(0);
            $read = ($length > 8192) ? 8192 : $length;
            $length -= $read;
            print(fread($fp,$read));
        }
        fclose($fp);
    }
    //just send the whole file
    else readfile($file);
    exit;
}
?>