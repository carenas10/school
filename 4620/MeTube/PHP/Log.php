<?php
require_once Path::php().'exceptions.php';

class Log {
	public static function logException(Exception $e) {
		$result = sprintf("Time: %s\n", date('Y-m-d H:i:s'));
		if(isset($_SESSION['userID'])) {
			$user = $_SESSION['userID'];
		} else {
			$user = 'none';
		}
		$result = sprintf("%sUser: %s\n", $result, $user);
		$result = sprintf("%sType: %s\n", $result, get_class($e));
		$result = sprintf("%sMessage: %s\n", $result, $e->getMessage());
		$result = sprintf("%sFile: %s\n", $result, $e->getFile());
		$result = sprintf("%sLine: %s\n", $result, $e->getLine());
		$result = sprintf("%sTrace: %s\n", $result, $e->getTraceAsString());
		$result = sprintf("%s\n", $result);
		//append $result to errors.log
		//3 flag specifies sending to file
		error_log($result, 3, Path::base().'errors.log');
	}
	public static function logMsg($message) {
		error_log($message."\n", 3, Path::base().'errors.log');
	}
}
?>