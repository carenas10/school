<?php
require_once Path::modelObjects().'Playlist.php';
require_once Path::formProcessors().'FormProcessor.php';

class RemovePlaylistMediaProcessor extends FormProcessor {
	//internal data
	private $playlist;
	private $mediaID;
	
	protected function collectFormInput() {
		$userID = $_SESSION['userID'];
		$this->mediaID = $this->trimAndEscape($_POST['mediaID']);
		if(!is_numeric($this->mediaID) || intval($this->mediaID) < 0) {
			$this->messages['mediaDoesNotExist'] = true;
		}
		$this->mediaID = intval($this->mediaID);
		
		$playlistID = $this->trimAndEscape($_POST['playlistID']);
		if(!is_numeric($playlistID) || intval($playlistID) < 0) {
			$this->messages['playlistDoesNotExist'] = true;
		} else if(!($this->playlist = Playlist::fromID(intval($playlistID))) ||
			$this->playlist->getUserID() != $userID) {
			$this->messages['playlistDoesNotExist'] = true;
		}
	}

	protected function process() {
		$this->playlist->removeMedia($this->mediaID);
		$this->messages['mediaRemovedFromPlaylist'] = true;
	}
	
	public function getFormValues() {
		return array();
	}
}

?>