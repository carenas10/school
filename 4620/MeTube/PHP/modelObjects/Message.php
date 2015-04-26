<?php
require_once Path::modelObjects().'Entity.php';

class Message extends Entity {
	private $content;
	private $timestamp;
	private $senderID;
	private $recipientID;
	
	public function __construct(array $row) {
		parent::__construct($row);
		$this->content = $row['content'];
		$this->timestamp = $row['timestamp'];
		$this->senderID = $row['senderID'];
		$this->recipientID = $row['recipientID'];
	}
	
	/* accessors */
	public function getContent() {
		return $this->content;
	}
	public function getTimestamp() {
		return $this->timestamp;
	}
	public function getSenderID() {
		return $this->senderID;
	}
	public function getRecipientID() {
		return $this->recipientID;
	}
	
	/* static functions */
	public static function create($threadID, $senderID, $recipientID, $content) {
		$conn = Connection::conn();
		$sql = sprintf("insert into Messages(threadID, senderID, recipientID, content) values(%d, %d, %d, '%s')",
			mysql_real_escape_string($threadID),
			mysql_real_escape_string($senderID),
			mysql_real_escape_string($recipientID),
			mysql_real_escape_string($content));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('send message failed');
		}
		return mysql_insert_id();
	}
}