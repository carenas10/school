<?php
require_once Path::modelObjects().'ModelObject.php';
require_once Path::modelObjects().'Media.php';

class Downloader extends ModelObject {
	public static function download(Media $media) {
		$file = $media->getPath();
		if (file_exists($file)) {
			header('Content-Description: File Transfer');
			header('Content-Type: application/octet-stream');
			header("Content-Disposition: attachment; filename=\"$file\"");
			header('Expires: 0');
			header('Cache-Control: must-revalidate');
			header('Pragma: public');
			header('Content-Length: ' . filesize($file));
			readfile($file);
			exit;
		} else {
			throw new InternalConsistencyException('Could not find file specified in Media db entry');
		}
	}
}
?>