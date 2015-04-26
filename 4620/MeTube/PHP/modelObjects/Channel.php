<?php
require_once Path::modelObjects().'ModelObject.php';
require_once Path::modelObjects().'Account.php';
require_once Path::modelObjects().'Media.php';

class Channel extends ModelObject {
	private $ownerAccount;
	
	public function __construct(Account $account) {
		$this->ownerAccount = $account;
	}
	
	/* accessors */
	public function getOwnerAccount() {
		return $this->ownerAccount;
	}
	//return media in no particular order
	public function getMedia() {
		$conn = Connection::conn();
		$sql = sprintf("select * from Media where userID='%d'", 
			mysql_real_escape_string($this->ownerAccount->getID()));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select media query failed');
		}
		$media = array();
		while($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
			$media[] = new Media($row);
		}
		return $media;
	}
}
?>