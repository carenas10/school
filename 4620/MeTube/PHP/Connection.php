<?php
class Connection {	
	public static function conn() {
		$dbhost = 'mysql1.cs.clemson.edu';
		$dbuser = 'MeTubeSQL_dian';
		$dbpass = 'purpleboards12';
		$dbname = 'MeTubeSQL_ii2t';

		$conn = mysql_connect($dbhost, $dbuser, $dbpass);
		if(!$conn) {
			throw new sqlException('connect to database failed');
		}
		if(!mysql_select_db($dbname)) {
			throw new sqlException('select table in database failed');
		}
		return $conn;
	}
}
?>