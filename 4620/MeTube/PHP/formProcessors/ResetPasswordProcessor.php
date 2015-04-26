<?php
require_once Path::modelObjects().'Account.php';
require_once Path::formProcessors().'FormProcessor.php';

class ResetPasswordProcessor extends FormProcessor {
	//collected data
	private $email = '';
	private $password = '';
	
	public static function isValidResetAttempt() {
		if(!isset($_GET['expirationTime']) || !isset($_GET['email']) || !isset($_GET['hash'])) {
			return false;
		}
		$expirationTime = $_GET['expirationTime'];
		$email = $_GET['email'];
		$allegedHash = $_GET['hash'];
		//if expiration time has passed or is too far in the future, then it is an invalid attempt
		//(expirationTime can only be too far in the future if hackers set the expirationTime
		//manually in URL)
		if(intval($expirationTime) < time() || intval($expirationTime) > time()+(15*60)) {
			return false;
		}
		$account = Account::fromEmail($email);
		if(!$account) {
			return false;
		}
		$passwordHash = $account->getPasswordHash();
		$hashString = $email.$expirationTime.$passwordHash;
		$realHash = hash('sha256', $hashString);
		if($allegedHash != $realHash) {
			return false;
		}
		return true;
	}
	
	protected function collectFormInput() {
		if(!self::isValidResetAttempt()) {
			$this->messages['invalidAttempt'] = true;
			return;
		}
		$this->email = $_GET['email'];
		
		$this->password = $_POST['password'];
		if(empty($this->password)) {
			$this->messages['passwordEmpty'] = true;
		}
		if($_POST['password'] != $_POST['confirmPassword']) {
			$this->messages['passwordsDoNotMatch'] = true;
		}
	}

	protected function process() {
		//hash password with new salt
		$salt = mt_rand(0, 65535);
		$passwordHash = hash('sha256', $this->password.$salt);
	
		$account = Account::fromEmail($this->email);
		$account->updatePassword($passwordHash, $salt);

		//if we got this far, everything succeeeded!
		$this->messages['userID'] = $account->getID();
		$this->messages['passwordReset'] = true;
	}
	
	public function getFormValues() {
		return array();
	}
}
?>