<?php
require_once Path::formProcessors().'FormProcessor.php';

class ForgotPasswordProcessor extends FormProcessor {
	//collected data
	private $emailOrUsername = '';
	
	//internal data
	private $account;
	
	protected function collectFormInput() {
		$this->emailOrUsername = $this->trimAndEscape($_POST['email']);
		if(strlen($this->emailOrUsername) > 255) {
			$this->messages['emailUsernameTooLong'] = true;
		}
		//try input as email, then as username if email fails
		if(!($this->account = Account::fromUsername($this->emailOrUsername)) &&
			!($this->account = Account::fromEmail($this->emailOrUsername))) {
			$this->messages['userUnfound'] = true;
		}
	}

	protected function process() {
		$email = $this->account->getEmail();
		$oldPasswordHash = $this->account->getPasswordHash();

		//expiration time is 15 minutes from now (15 minutes * 60 seconds)
		$expirationTime = time() + (15 * 60);
		
		//the hash string embeds all information we want to convey in URL to check on other side
		$hashString = $email.$expirationTime.$oldPasswordHash;
		
		$hash = hash('sha256', $hashString);
		$url = Path::externalRoot()."resetPassword?expirationTime=$expirationTime&email=$email&hash=$hash";
		
		$message = "Please follow the following link to reset your password: $url";
		mail($email, 'Reset Password for MeTube', $message);
		
		$this->messages['sentResetPasswordLink'] = true;
	}
	
	public function getFormValues() {
		return array(
			"email" => "$this->emailOrUsername"
		);
	}
}

?>