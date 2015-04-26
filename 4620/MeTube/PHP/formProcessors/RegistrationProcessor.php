<?php
require_once Path::modelObjects().'Account.php';
require_once Path::formProcessors().'FormProcessor.php';

class RegistrationProcessor extends FormProcessor {
	//collected data
	private $username = '';
	private $email = '';
	private $password = '';
	
	protected function collectFormInput() {
		$this->username = $this->trimAndEscape($_POST['username']);
		if(empty($this->username)) {
			$this->messages['usernameEmpty'] = true;
		} else if(strlen($this->username) > 35) {
			$this->messages['usernameTooLong'] = true;
		}
		if(strpos($this->username, '@') !== false) {
			$this->messages['usernameContains@Symbol'] = true;
		}
		if(Account::fromUsername($this->username)) {
			$this->messages['usernameTaken'] = true;
		}
		
		$this->email = $this->trimAndEscape($_POST['email']);
		$this->email = strtolower($this->email);
		if(strlen($this->email) > 255) {
			$this->messages['emailTooLong'] = true;
		} else if(!filter_var($this->email, FILTER_VALIDATE_EMAIL)) {
    		$this->messages['emailInvalid'] = true;
		} else if(Account::fromEmail($this->email)) {
			$this->messages['emailTaken'] = true;
		}
		
		$this->password = $_POST['password'];
		if(empty($this->password)) {
			$this->messages['passwordEmpty'] = true;
		}
		if($_POST['password'] != $_POST['confirmPassword']) {
			$this->messages['passwordsDoNotMatch'] = true;
		}
	}

	protected function process() {
		//hash password with salt
		$salt = mt_rand(0, 65535);
		$passwordHash = hash('sha256', $this->password.$salt);
	
		$accountID = Account::create($this->username, $this->email, $passwordHash, $salt);

		//if we got this far, everything succeeeded!
		$_SESSION['userID'] = $accountID;
		$this->messages['registrationSuccessful'] = true;
	}
	
	public function getFormValues() {
		return array(
			"username" => "$this->username",
			"email" => "$this->email"
		);
	}
}
?>