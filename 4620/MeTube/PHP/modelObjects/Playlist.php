<?php
require_once Path::modelObjects().'Entity.php';
require_once Path::modelObjects().'Media.php';

class Playlist extends Entity {
	private $name;
	private $userID;
	
	public function __construct(array $row) {
		parent::__construct($row);
		$this->name = $row['name'];
		$this->userID = $row['userID'];
	}
	
	/* accessors */
	public function getName() {
		return $this->name;
	}
	public function getUserID() {
		return $this->userID;
	}
	//return media in no particular order
	public function getMedia() {
		$conn = Connection::conn();
		//get media id's
		$sql = sprintf("select mediaID from PlaylistMedia where playlistID=%d", 
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select playlist media ids query failed');
		}
		$mediaIDs = array();
		while($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
			$mediaIDs[] = $row['mediaID'];
		}
		
		//get media for id's
		$media = array();
		foreach($mediaIDs as $mediaID) {
			$sql = sprintf("select * from Media where id=%d", 
				mysql_real_escape_string($mediaID));
			$retval = mysql_query($sql, $conn);
			if(!$retval) {
				throw new sqlException('select playlist media query failed');
			}
			if($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
				$media[] = new Media($row);
			} else {
				throw new InternalConsistencyException('PlaylistMedia had mediaID not found in Media');
			}
		}
		
		return $media;
	}
	public function containsMedia($mediaID) {
		if(!is_string($mediaID) && !is_int($mediaID)) {
			throw new InvalidArgumentException();
		}
		$conn = Connection::conn();
		$sql = sprintf("select * from PlaylistMedia where playlistID=%d and mediaID=%d", 
			mysql_real_escape_string($this->id),
			mysql_real_escape_string($mediaID));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select media failed');
		}
		if($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
			return true;
		} else {
			return false;
		}
	}
	
	/* mutators */
	public function addMedia($mediaID) {
		if(!is_string($mediaID) && !is_int($mediaID)) {
			throw new InvalidArgumentException();
		}
		$conn = Connection::conn();
		//get media id's
		$sql = sprintf("insert into PlaylistMedia(playlistID, mediaID) values(%d, %d)", 
			mysql_real_escape_string($this->id),
			mysql_real_escape_string($mediaID));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('add media to playlist failed');
		}
	}
	public function removeMedia($mediaID) {
		if(!is_string($mediaID) && !is_int($mediaID)) {
			throw new InvalidArgumentException();
		}
		$conn = Connection::conn();
		$sql = sprintf("delete from PlaylistMedia where playlistID=%d and mediaID=%d", 
			mysql_real_escape_string($this->id),
			mysql_real_escape_string($mediaID));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException("remove media from playlist failed");
		}
	}
	public function delete() {
		$conn = Connection::conn();
		$sql = sprintf("delete from Playlists where id=%d",
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('delete playlist failed');
		}
		//PlaylistMedia entries will automatically delete by cascade
	}
	
	/* static functions */
	public static function fromID($playlistID) {
		if(!(is_int($playlistID) || is_string($playlistID))) {
			throw new InvalidArgumentException();
		}
		$conn = Connection::conn();
		$sql = sprintf("select * from Playlists where id=%d", 
			mysql_real_escape_string($playlistID));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select playlist query failed');
		}
		if(!($row = mysql_fetch_array($retval, MYSQL_ASSOC))) {
			//no playlist with $playlistID found
			return false;
		}
		return new Playlist($row);
	}
	public static function create($name, $userID) {
		$conn = Connection::conn();
		$sql = sprintf("insert into Playlists(userID, name) values(%d, '%s')",
			mysql_real_escape_string($userID),
			mysql_real_escape_string($name));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('create playlist failed');
		}
		return mysql_insert_id();
	}
}
?>