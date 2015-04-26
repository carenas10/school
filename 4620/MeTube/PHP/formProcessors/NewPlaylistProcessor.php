<?php
require_once Path::modelObjects().'Playlist.php';
require_once Path::formProcessors().'FormProcessor.php';

class NewPlaylistProcessor extends FormProcessor {
	//collected data
	private $name = '';
	private $userID;
	
	protected function collectFormInput() {
		$this->userID = $_SESSION['userID'];
		
		$this->name = $this->trimAndEscape($_POST['newPlaylistName']);
		if(empty($this->name)) {
			$this->messages['playlistNameEmpty'] = true;
		} else if(strlen($this->name) > 35) {
			$this->messages['playlistNameTooLong'] = true;
		}
	}

	protected function process() {
		Playlist::create($this->name, $this->userID);
		$this->messages['playlistCreated'] = true;
	}
	
	public function getFormValues() {
		return array(
			"newPlaylistName" => "$this->name",
		);
	}
}

?>