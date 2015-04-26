<?php
require_once Path::modelObjects().'Playlist.php';
require_once Path::formProcessors().'FormProcessor.php';

class DeletePlaylistProcessor extends FormProcessor {
	//internal data
	private $playlist;
	
	protected function collectFormInput() {
		$userID = $_SESSION['userID'];
		
		$playlistID = $this->trimAndEscape($_POST['playlistID']);
		if(!is_numeric($playlistID) || intval($playlistID) < 0) {
			$this->messages['playlistDoesNotExist'] = true;
		} else if(!($this->playlist = Playlist::fromID(intval($playlistID))) ||
			$this->playlist->getUserID() != $userID) {
			$this->messages['playlistDoesNotExist'] = true;
		}
	}

	protected function process() {
		$this->playlist->delete();
		$this->messages['playlistDeleted'] = true;
	}
	
	public function getFormValues() {
		return array();
	}
}
?>