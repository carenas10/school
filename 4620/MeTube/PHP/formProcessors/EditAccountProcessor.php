<?php
require_once Path::modelObjects().'Account.php';
require_once Path::formProcessors().'FormProcessor.php';

class EditAccountProcessor extends FormProcessor {
	//collected data
	private $newUsername = '';
	private $newEmail = '';
	private $newPassword = '';
	
	//internal data
	private $account;
	
	public function __construct() {
		$accountID = $_SESSION['userID'];
		$this->account = Account::fromID($accountID);
		$this->newUsername = $this->account->getUsername();
		$this->newEmail = $this->account->getEmail();
	}
	
	protected function collectFormInput() {
		$this->newUsername = $this->trimAndEscape($_POST['username']);
		if(empty($this->newUsername)) {
			$this->messages['usernameEmpty'] = true;
		} else if(strlen($this->newUsername) > 35) {
			$this->messages['usernameTooLong'] = true;
		}
		if(strpos($this->newUsername, '@') !== false) {
			$this->messages['usernameContains@Symbol'] = true;
		}
		if(strtolower($this->newUsername) != strtolower($this->account->getUsername()) &&
			Account::fromUsername($this->newUsername)) {
			$this->messages['usernameTaken'] = true;
		}
		
		$this->newEmail = $this->trimAndEscape($_POST['email']);
		$this->newEmail = strtolower($this->newEmail);
		if(strlen($this->newEmail) > 255) {
			$this->messages['emailTooLong'] = true;
		} else if(!filter_var($this->newEmail, FILTER_VALIDATE_EMAIL)) {
    		$this->messages['emailInvalid'] = true;
		} else if(strtolower($this->newEmail) != strtolower($this->account->getEmail()) &&
			Account::fromEmail($this->newEmail)) {
			$this->messages['emailTaken'] = true;
		}
		
		$this->newPassword = $_POST['password'];
	}

	protected function process() {	
		//update username and email
		$this->account->updateEmail($this->newEmail);
		$this->account->updateUsername($this->newUsername);
		
		//updat password only if a new password was sent
		if(!empty($this->newPassword)) {
			$salt = mt_rand(0, 65535);
			$passwordHash = hash('sha256', $this->newPassword.$salt);
			
			$this->account->updatePassword($passwordHash, $salt);
		}

		//if we got this far, everything succeeeded!
		$this->messages['updateSuccessful'] = true;
	}
	
	public function getFormValues() {
		return array(
			"username" => $this->newUsername,
			"email" => $this->newEmail
		);
	}
}
?>