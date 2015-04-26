<?php
require_once Path::modelObjects().'Account.php';
require_once Path::formProcessors().'FormProcessor.php';

class LoginProcessor extends FormProcessor {
	//collected data
	private $emailOrUsername = '';
	private $password = '';
	
	protected function collectFormInput() {
		$this->emailOrUsername = $this->trimAndEscape($_POST['email']);
		if(strlen($this->emailOrUsername) > 255) {
			$this->messages['emailUsernameTooLong'] = true;
		}
		$this->password = $_POST['password'];
	}

	protected function process() {
		//try input as email, then as username if email fails
		if(!($account = Account::fromEmail($this->emailOrUsername)) &&
			!($account = Account::fromUsername($this->emailOrUsername))) {
			$this->messages['incorrectCredentials'] = true;
			return;
		}

		//hash password and compare with stored hash
		$salt = $account->getPasswordSalt();
		$passwordHash = hash('sha256', $this->password.$salt);
		if($passwordHash != $account->getPasswordHash()) {
			$this->messages['incorrectCredentials'] = true;
		} else {
			//login successful
			$this->messages['loginSuccessful'] = true;
			$_SESSION['userID'] = $account->getID();
			
			//redirect user to page user originally requested if user got redirected to login
			if($_SESSION['desiredPage']) {
				$desiredPage = $_SESSION['desiredPage'];
				unset($_SESSION['desiredPage']);
				header("Location: $desiredPage");
				exit;
			}
		}
	}
	
	public function getFormValues() {
		return array(
			"email" => "$this->emailOrUsername"
		);
	}
}

?>