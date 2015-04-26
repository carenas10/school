<?php
require_once Path::modelObjects().'Entity.php';

class Comment extends Entity {
	private $commenterID;
	private $content;

	public function __construct(array $row) {
		parent::__construct($row);
		$this->commenterID = $row['userID'];
		$this->content = $row['content'];
	}

	/* accessors */
	public function getContent() {
		return $this->content;
	}
	public function getCommenterID() {
		return $this->commenterID;
	}
	
	/* static functions */
	public static function create($mediaID, $userID, $comment) {
		$conn = Connection::conn();
		$sql = sprintf("insert into Comments(mediaID, userID, content) values(%d, %d, '%s')",
			mysql_real_escape_string($mediaID),
			mysql_real_escape_string($userID),
			mysql_real_escape_string($comment));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('create comment failed');
		}
		return mysql_insert_id();
	}
}
?>