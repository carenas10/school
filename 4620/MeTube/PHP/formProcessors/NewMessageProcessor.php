<?php
require_once Path::modelObjects().'Account.php';
require_once Path::modelObjects().'Thread.php';
require_once Path::formProcessors().'FormProcessor.php';

class NewMessageProcessor extends FormProcessor {
	//collected data
	private $recipient = '';
	private $content = '';
	
	//internal data
	private $senderID;
	private $recipientID;

	protected function collectFormInput() {
		$this->senderID = $_SESSION['userID'];
		
		$this->recipient = $this->trimAndEscape($_POST['messageRecipient']);
		if(empty($this->recipient)) {
			$this->messages['recipientEmpty'] = true;
		} else if(!($recipientAccount = Account::fromUsername($this->recipient)) &&
			!($recipientAccount = Account::fromEmail($this->recipient))) {
			$this->messages['recipientDoesNotExist'] = true;
		} else {
			$this->recipientID = $recipientAccount->getID();
			if($this->recipientID == $this->senderID) {
				$this->messages['messageToSelf'] = true;
			}
		}
		
		$this->content = $this->trimAndEscape($_POST['messageContent']);
		if(empty($this->content)) {
			$this->messages['contentEmpty'] = true;
		} else if(strlen($this->content) > 65535) {
			$this->messages['contentTooLong'] = true;
		}
	}

	protected function process() {		
		//check if thread already exists between sender and recipient
		//if not, create new thread
		if(!$thread = Thread::fromUserIDs($this->senderID, $this->recipientID)) {
			$threadID = Thread::create($this->senderID, $this->recipientID);
			$thread = Thread::fromID($threadID);
		}
		$thread->sendMessage($this->content, $this->senderID);
		$this->messages['threadID'] = $thread->getID();
		$this->messages['messageSentSuccessfully'] = true;
	}
	
	public function getFormValues() {
		return array(
			"messageRecipient" => "$this->recipient",
			"messageContent" => "$this->content"
		);
	}
}

?>