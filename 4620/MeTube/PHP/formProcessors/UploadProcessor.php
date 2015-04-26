<?php
require_once Path::formProcessors().'FormProcessor.php';
require_once Path::modelObjects().'Media.php';

class UploadProcessor extends FormProcessor {
	//form data
	private $title = '';
	private $description = '';
	private $keywordsString = '';
	private $selectedCategory = '';
	
	//internal data
	private $keywords = array();
	private $fileExt;
	
	private function codeToMessage($code) {
		switch ($code) {
		case UPLOAD_ERR_INI_SIZE:
			return 'fileTooLarge';
		case UPLOAD_ERR_FORM_SIZE:
			return 'fileTooLarge';
		case UPLOAD_ERR_PARTIAL:
			return 'partialUpload';
		case UPLOAD_ERR_NO_FILE:
			return 'noFile';
		case UPLOAD_ERR_NO_TMP_DIR:
			return 'noTempDir';
		case UPLOAD_ERR_CANT_WRITE:
			return 'cantWrite';
		case UPLOAD_ERR_EXTENSION:
			return 'extensionPreventedUpload';
		default:
			return 'unknownUploadError';
		}
	}
	
	protected function collectFormInput() {
		$this->title = $this->trimAndEscape($_POST['title']);
		if(empty($this->title)) {
			$this->messages['emptyTitle'] = true;
		} else if(strlen($this->title) > 70) {
			$this->messages['titleTooLong'] = true;
		}
		
		$this->description = $this->trimAndEscape($_POST['description']);
		if(empty($this->description)) {
			$this->messages['emptyDescription'] = true;
		} else if(strlen($this->description) > 255) {
			$this->messages['descriptionTooLong'] = true;
		}
		
		$this->keywordsString = $this->trimAndEscape($_POST['keywords']);
		//replace each group of whitespace with a single space
		$this->keywordsString = preg_replace('!\s+!', ' ', $this->keywordsString);
		$this->keywords = array_filter(explode(',', $this->keywordsString));
		foreach($this->keywords as $key=>$keyword) {
			//trim whitespace
			$this->keywords[$key] = trim($keyword);
			if(strlen($keyword) > 35) {
				$this->messages['keywordTooLong'] = true;
			}
		}
		
		/*
			No need to trimAndEscape category because value should be selected from a dropdown.
			If user were to manipulate dropdown values, he could do no harm because the value
			is never displayed to front end and getCategories() check would catch the error.
			
			If we did use html_special_chars on the $_POST['category'], then some chars
			would be escaped, making them mismatch corresponding string in database.
		*/
		$this->selectedCategory = $_POST['category'];
		if(!in_array($this->selectedCategory, Media::getCategories())) {
			$this->messages['categoryDoesNotExist'] = true;
		}
		
		if(empty($_FILES['fileToUpload']['name'])) {
			$this->messages['noFileSelected'] = true;
		} else if($_FILES['fileToUpload']['error'] !== UPLOAD_ERR_OK) {
			$message = $this->codeToMessage($_FILES['fileToUpload']['error']);
			//if fileTooLarge, send message to user. Otherwise throw exception.
			if($message == 'fileTooLarge') {
				$this->messages['fileTooLarge'] = true;
			} else {
				throw new ServerFailedException($message);
			}
		}
		
		if(!$this->asImage() && !$this->asAudio() && !$this->asVideo()) {
			$this->messages['invalidFileType'] = true;
		}
	}
	private function asImage() {
		//check file as image
		$info = getimagesize($_FILES['fileToUpload']['tmp_name']);
		//if not an image, or width or height are zero
		if(!$info || $info[0] == 0 || $info[1] == 0) {
			return false;
		} else {
			$imageType = $info[2];
			$this->fileExt = image_type_to_extension($imageType, false);
			$this->type = 'image';
			return true;
		}
	}
	private function asAudio() {
		//get file extension
		$fileNameComponents = explode(".", $_FILES["fileToUpload"]["name"]);
		$fileExt = end($fileNameComponents);
		if(count($fileNameComponents) <= 1 || strtolower($fileExt) != 'mp3') {
			return false;
		} else {
			$this->fileExt = 'mp3';
			$this->type = 'audio';
			return true;
		}
	}
	private function asVideo() {
		//get file extension
		$fileNameComponents = explode(".", $_FILES["fileToUpload"]["name"]);
		$fileExt = end($fileNameComponents);
		if(count($fileNameComponents) <= 1 || strtolower($fileExt) != 'mp4') {
			return false;
		} else {
			$this->fileExt = 'mp4';
			$this->type = 'video';
			return true;
		}
	}

	protected function process() {	
		$mediaID = Media::create($this->title, $this->description, $this->keywords,
			$_SESSION['userID'], $this->selectedCategory, $this->fileExt,
			$this->type, $_FILES['fileToUpload']['tmp_name']);
		$this->messages['uploadSuccessful'] = true;
		$this->messages['mediaID'] = $mediaID;
	}

	public function getFormValues() {
		return array(
			'title' => "$this->title",
			'description' => "$this->description",
			'keywords' => "$this->keywordsString",
			'selectedCategory' => "$this->selectedCategory"
		);
	}
}

?>