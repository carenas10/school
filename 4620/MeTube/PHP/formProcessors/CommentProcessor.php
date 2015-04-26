<?php
require_once Path::modelObjects().'Media.php';
require_once Path::formProcessors().'FormProcessor.php';

class CommentProcessor extends FormProcessor {
	//collected data
	private $comment = '';
	
	//internal data
	private $commenterID;
	private $media;
		
	protected function collectFormInput() {
		$this->commenterID = $_SESSION['userID'];
		$mediaID = $_GET['mediaID'];
		$this->media = Media::fromID($mediaID);
		
		$this->comment = $this->trimAndEscape($_POST['newCommentContent']);
		if(empty($this->comment)) {
			$this->messages['commentEmpty'] = true;
		} else if(strlen($this->comment) > 500) {
			$this->messages['commentTooLong'] = true;
		}
	}

	protected function process() {
		$this->media->addComment($this->comment, $this->commenterID);
		$this->messages['commentedSuccessfully'] = true;
	}
	
	public function getFormValues() {
		return array(
			"newCommentContent" => "$this->comment"
		);
	}
}

?>