<?php
require_once Path::modelObjects().'ModelObject.php';
/*	
	1) Unlike the more general ModelObject, an Entity has a one-to-one
		correspondence with a single entity in the database. Entity corresponds to an
		entity in the ER model.
	2) Generally, a ModelObject could encapsulate logic for a group of entities in the
		database.
		For example, the Inbox class encapsulates logic about all threads pertaining to a
		single user. But Inbox does not have a one-to-one correspondence with a row in the
		database. So Inbox is not an Entity.
		On the other hand, the Comment class does have a one-to-one correspondence with
		a row in the database. So Comment is an Entity.
*/
abstract class Entity extends ModelObject {
	protected $id;
	
	//$dbRow should be a row from the database
	//$dbRow must be the result of a call to mysql_fetch_array(..., MYSQL_ASSOC)
	protected function __construct(array $dbRow) {
		$this->id = $dbRow['id'];
	}
	
	public function getID() {
		return $this->id;
	}
}
?>