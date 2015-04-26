<?php
require_once Path::modelObjects().'Entity.php';
require_once Path::modelObjects().'Message.php';
require_once Path::modelObjects().'Account.php';

class Thread extends Entity {
	private $user1ID;
	private $user2ID;
	
	public function __construct(array $row) {
		parent::__construct($row);
		$this->user1ID = $row['user1ID'];
		$this->user2ID = $row['user2ID'];
	}
	
	/* accessors */
	public function getUser1ID() {
		return $this->user1ID;
	}
	public function getUser2ID() {
		return $this->user2ID;
	}
	public function getMostRecentMessage() {
		$conn = Connection::conn();
		$sql = sprintf("select * from Messages where threadID=%d order by timestamp desc limit 1",
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select most recent message query failed');
		}
		if($row = mysql_fetch_array($retval)) {
			return new Message($row);
		} else {
			return false;
		}
	}
	public function getMessages() {
		$conn = Connection::conn();
		$sql = sprintf("select * from Messages where threadID=%d order by timestamp asc",
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select messages query failed');
		}
		$messages = array();
		while($row = mysql_fetch_array($retval)) {
			$messages[] = new Message($row);
		}
		return $messages;
	}

	/* mutators */
	public function sendMessage($content, $senderID) {
		if($this->user1ID == $senderID && $this->user2ID == $senderID) {
			throw new InvalidArgumentException('senderID does not match either thread user ids');
		}
		$recipientID = $senderID == $this->user1ID? $this->user2ID : $this->user1ID;
		return Message::create($this->id, $senderID, $recipientID, $content);
	}

	/* static functions */
	public static function fromID($threadID) {
		if(!is_int($threadID) and !is_string($threadID)) {
			throw new InvalidArgumentException();
		}
		$conn = Connection::conn();
		$sql = sprintf("select * from MessageThreads where id=%d",
			mysql_real_escape_string($threadID));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select thread query failed');
		}
		if(!($row = mysql_fetch_array($retval, MYSQL_ASSOC))) {
			return false;
		}
		return new Thread($row);
	}
	public static function fromUserIDs($user1ID, $user2ID) {
		if(!is_int($user1ID) and !is_string($user1ID)) {
			throw new InvalidArgumentException();
		}
		if(!is_int($user2ID) and !is_string($user2ID)) {
			throw new InvalidArgumentException();
		}
		$conn = Connection::conn();
		$sql = sprintf("select * from MessageThreads where (user1ID=%d and user2ID=%d) or (user1ID=%d and user2ID=%d)",
			mysql_real_escape_string($user1ID),
			mysql_real_escape_string($user2ID),
			mysql_real_escape_string($user2ID),
			mysql_real_escape_string($user1ID));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select thread id query failed');
		}
		if(!($row = mysql_fetch_array($retval, MYSQL_ASSOC))) {
			return false;
		}
		return new Thread($row);
	}
	public static function create($user1ID, $user2ID) {
		$conn = Connection::conn();
		$sql = sprintf("insert into MessageThreads(user1ID, user2ID) values(%d, %d)",
			mysql_real_escape_string($user1ID),
			mysql_real_escape_string($user2ID));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('create new message thread failed');
		}
		return mysql_insert_id();
	}
}
?>