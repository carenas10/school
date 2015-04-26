<?php
/*
	Description:
	Abstract class for handling forms.
	
	Subclasses must override the following three functions:
		1. collectFormInput()
		2. process()
		3. getFormValues()
*/
require_once Path::php().'exceptions.php';
require_once Path::php().'Connection.php';

abstract class FormProcessor {
	//hold all errors/messages to return to UI
	//message is key, value is boolean true
	protected $messages = array();
	
	protected function trimAndEscape($data) {
		$data = trim($data);
		$data = htmlspecialchars($data);
		return $data;
	}
	
	abstract protected function collectFormInput();
	//guaranteed to be no form collection errors when this function is called
	abstract protected function process();
	
	//template method that connects to sql, collects form input, then defers to 
	//subclass method process() for real processing
	public function processForm() {
		$this->collectFormInput();
		//only process if there are no form errors
		if(count($this->messages) == 0) {
			//do the real work
			$this->process();
		}
	}
	
	/*
		Returns an array with form input names as indices and form values as values.
		This method is useful if, say, the user's email address did not validate.
		A front-facing page can call getFormValues() to retrieve the user's invalid
		email address and populate the form with this value so that users can still
		see their mistakes.
		The default value mapped to a form input name is the empty string.
	*/
	abstract public function getFormValues();
	
	/*
		returns an array with messages as indices mapped to boolean true values.
		For example, if processing was successful, the processor might set
		$this->messages['processingSuccessful'] = true;
		A client can then use isset(getMessages()['processingSuccessful']) to check
		whether the form was processed successfully or not.
	*/
	public function getMessages() {
		return $this->messages;
	}
}
?>