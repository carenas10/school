<?php
require_once Path::modelObjects().'Playlist.php';
require_once Path::formProcessors().'FormProcessor.php';

class AddToPlaylistProcessor extends FormProcessor {
	//collected data
	private $playlistID = '';
	
	//internal data
	private $mediaID;
	private $playlist;
		
	protected function collectFormInput() {
		$userID = $_SESSION['userID'];
		$this->mediaID = $_GET['mediaID'];
		
		$this->playlistID = $this->trimAndEscape($_POST['playlistID']);
		if(!is_numeric($this->playlistID) || intval($this->playlistID) < 0) {
			$this->messages['playlistDoesNotExist'] = true;
		} else if(!($this->playlist = Playlist::fromID(intval($this->playlistID))) ||
			$this->playlist->getUserID() != $userID) {
			$this->messages['playlistDoesNotExist'] = true;
		} else if($this->playlist->containsMedia($this->mediaID)) {
			$this->messages['mediaAlreadyInPlaylist'] = true;
		}
	}

	protected function process() {
		$this->playlist->addMedia($this->mediaID);
		$this->messages['addedMediaToPlaylist'] = true;
	}
	
	public function getFormValues() {
		return array(
			"playlistID" => "$this->playlistID"
		);
	}
}

?>