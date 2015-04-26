<?php
require_once Path::modelObjects().'Entity.php';
require_once Path::php().'Log.php';
require_once Path::modelObjects().'Channel.php';
require_once Path::modelObjects().'Playlist.php';

class Account extends Entity {
	private $username;
	private $email;
	private $channel;
	private $passwordHash;
	private $passwordSalt;
	
	protected function __construct(array $row) {
		parent::__construct($row);
		$this->email = $row['email'];
		$this->username = $row['username'];
		$this->passwordHash = $row['passwordHash'];
		$this->passwordSalt = $row['passwordSalt'];
	}
	
	/* accessors */
	public function getEmail() {
		return $this->email;
	}
	public function getUsername() {
		return $this->username;
	}
	public function getPasswordHash() {
		return $this->passwordHash;
	}
	public function getPasswordSalt() {
		return $this->passwordSalt;
	}
	public function getChannel() {
		//lazily instantiate channel
		if(!isset($this->channel)) {
			$this->channel = new Channel($this);
		}
		return $this->channel;
	}
	public function getPlaylists() {
		$playlists = array();
		
		//get playlists
		$conn = Connection::conn();
		$sql = sprintf("select * from Playlists where userID=%d", 
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('get playlists query failed');
		}

		while($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
			$playlists[] = new Playlist($row);
		}
		return $playlists;
	}
	public function getSubscribedChannels() {
		//refetch subscribed channels with each call to prevent stale data and old references
		$subscribedChannels = array();
		
		//get channels
		$conn = Connection::conn();
		$sql = sprintf("select * from Subscriptions where subscriberID=%d", 
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('get subscriptions query failed');
		}

		while($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
			$channelOwnerAccount = self::fromID($row['channelOwnerID']);
			if(!$channelOwnerAccount) {
				throw new InternalConsistencyException('subscription says channel exists but could not get owner account');
			}
			$subscribedChannels[] = new Channel($channelOwnerAccount);
		}
		return $subscribedChannels;
	}
	public function isSubscribed($channelOwnerID) {
		$conn = Connection::conn();
		$sql = sprintf('select * from Subscriptions where subscriberID=%d && channelOwnerID=%d',
			mysql_real_escape_string($this->id),
			mysql_real_escape_string($channelOwnerID));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('get subscriptions query failed');
		}
		if(!($row = mysql_fetch_array($retval, MYSQL_ASSOC))) {
			return false;
		} else {
			return true;
		}
	}
	public function getFavorites() {
		$conn = Connection::conn();
		$sql = sprintf("select * from FavoriteMedia where userID=%d",
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('get favorite media query failed');
		}
		$favorites = array();
		while($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
			$media = Media::fromID($row['mediaID']);
			if(!$media) {
				throw new InternalConsistencyException('could not find media for mediaID in FavoriteMedia');
			}
			$favorites[] = $media;
		}
		return $favorites;
	}
	public function isFavorite($mediaID) {
		$conn = Connection::conn();
		$sql = sprintf("select * from FavoriteMedia where mediaID=%d and userID=%d",
			mysql_real_escape_string($mediaID),
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('get favorite media query failed');
		}
		if($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
			return true;
		} else {
			return false;
		}
	}
	
	/* mutators */
	public function updateEmail($email) {
		$conn = Connection::conn();
		$sql = sprintf("update UserAccounts set email='%s' where id=%d",
			mysql_real_escape_string($email),
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('update email failed');
		}
	}
	public function updateUsername($username) {
		$conn = Connection::conn();
		$sql = sprintf("update UserAccounts set username='%s' where id=%d",
			mysql_real_escape_string($username),
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('update username failed');
		}
	}
	public function updatePassword($passwordHash, $passwordSalt) {
		$conn = Connection::conn();
		$sql = sprintf("update UserAccounts set passwordHash='%s', passwordSalt=%d where id=%d",
			mysql_real_escape_string($passwordHash),
			mysql_real_escape_string($passwordSalt),
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('update password failed');
		}
	}
	public function subscribe($channelOwnerID) {
		$conn = Connection::conn();
		$sql = sprintf('insert into Subscriptions(subscriberID, channelOwnerID)'.
			' values '.
			'(%d, %d)', 
			mysql_real_escape_string($this->id),
			mysql_real_escape_string($channelOwnerID));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('insert subscription query failed');
		}
	}
	public function unsubscribe($channelOwnerID) {
		$conn = Connection::conn();
		$sql = sprintf('delete from Subscriptions where subscriberID=%d && channelOwnerID=%d',
			mysql_real_escape_string($this->id),
			mysql_real_escape_string($channelOwnerID));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('delete subscription query failed');
		}
	}
	public function favorite($mediaID) {
		$conn = Connection::conn();
		$sql = sprintf("insert into FavoriteMedia(mediaID, userID) values (%d, %d)",
			mysql_real_escape_string($mediaID),
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('make media favorite failed');
		}
	}
	public function unfavorite($mediaID) {
		$conn = Connection::conn();
		$sql = sprintf("delete from FavoriteMedia where mediaID=%d and userID=%d",
			mysql_real_escape_string($mediaID),
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('remove favorite media failed');
		}
	}
	public function delete() {
		//delete all files belonging to user
		$conn = Connection::conn();
		$sql = sprintf("select * from Media where userID='%d'",
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select media for user query failed');
		}
		while($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
			$media = new Media($row);
			$media->delete();
		}
	
		//delete account in database
		$sql = sprintf("delete from UserAccounts where id='%d'",
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('delete user account query failed.');
		}
	}
	
	/* static functions */
	public static function fromID($userID) {
		if(!(is_int($userID) || is_string($userID))) {
			throw new InvalidArgumentException();
		}
		$conn = Connection::conn();
		$sql = sprintf("select * from UserAccounts where id=%d", 
			mysql_real_escape_string($userID));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select user account query failed');
		}
		if(!($row = mysql_fetch_array($retval, MYSQL_ASSOC))) {
			//no account with $userID found
			return false;
		}
		return new Account($row);
	}
	public static function fromEmail($email) {
		if(!(is_string($email))) {
			throw new InvalidArgumentException();
		}
		$conn = Connection::conn();
		$sql = sprintf("select * from UserAccounts where email='%s'", 
			mysql_real_escape_string($email));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select user account query failed');
		}
		if(!($row = mysql_fetch_array($retval, MYSQL_ASSOC))) {
			//no account with $email found
			return false;
		}
		return new Account($row);
	}
	public static function fromUsername($username) {
		if(!(is_string($username))) {
			throw new InvalidArgumentException();
		}
		$conn = Connection::conn();
		$sql = sprintf("select * from UserAccounts where username='%s'", 
			mysql_real_escape_string($username));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select user account query failed');
		}
		if(!($row = mysql_fetch_array($retval, MYSQL_ASSOC))) {
			//no account with $username found
			return false;
		}
		return new Account($row);
	}
	public static function create($username, $email, $passwordHash, $passwordSalt) {
		$conn = Connection::conn();
		$sql = sprintf("insert into UserAccounts " .
			"(username, email, passwordHash, passwordSalt) ".
			"values ".
			"('%s', '%s', '%s', %d)",
			mysql_real_escape_string($username),
			mysql_real_escape_string($email),
			mysql_real_escape_string($passwordHash),
			mysql_real_escape_string($passwordSalt));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('insert user query failed');
		}
		return mysql_insert_id();
	}
	public static function getAllAccounts() {
		$conn = Connection::conn();
		$sql = sprintf('select * from UserAccounts order by id');
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select all users query failed');
		}
		$results = array();
		while($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
			$results[] = new Account($row);
		}
		return $results;
	}
}
?>