<?php
/*
	This code manages all form processor objects for a front-end form page.
	Each page can have more than one form processor object.
	This code performs the following tasks:
	
	1. Instantiates form processor objects (specified in $processorClasses array)
	2. Calls processForm() on a processor object when the processor's form is posted
		(in $_POST)
	3. After processing a form, stores the processor object in $_SESSION and reloads the
		page. This is to prevent the same form being posted again when the user reloads
		the page.
	4. Retrieves the messages and form values from each processor object and accumulates
		all messages and form values into $msg and $values respectively.
		
	The following variables must be defined before including this code:
	$processorClasses - specifies the class names of the processor objects
	$postSignals - specifies any value in the form of the corresponding processorClass
	$processorClasses and $postSignals must be the same length.
	The ith post signal is a signal for the ith processor class.
	
	For example, suppose we have two forms on the page, a new playlist form and an edit
	playlist form, with corresponding processor classes NewPlaylistProcessor and
	EditPlaylistProcessor. If the name of the submit button in the new playlist form is
	"createNewPlaylist" and the name of the submit button in the edit playlist form is
	"editPlaylist", then the variables would be set up like this:
	
	$processorClasses = array("NewPlaylistProcessor", "EditPlaylistProcessor");
	$postSignals = array("createNewPlaylist", "editPlaylist");
	
	include "formHandlerCode.php";
	
	...
	
	IMPORTANT: Because all messages and values from all processors objects are accumulated
	into two arrays, $msg and $values, all message names and all form value names must be
	unique.
	If EditPlaylistProcessor sends a message "PlaylistNameEmpty" and
	NewPlaylistProcessor sends a message "PlaylistNameEmpty", then one message will
	overwrite the other. In this case put the forms on separate pages or change the 
	message names.
*/

$msg = array(); //store all messages from all processors
$values = array(); //store all values from all processors
foreach($processorClasses as $i=>$processorClass) {
	//try to retrieve processor object from session variable
	//otherwise create new processor object
	if(isset($_SESSION['processor'.$i])) {
		$processor = $_SESSION['processor'.$i];
		unset($_SESSION['processor'.$i]);
	} else {
		$processor = new $processorClass();
	}
	//accumulate messages and form values to $msg and $values
	$msg = array_merge($msg, $processor->getMessages());
	$values = array_merge($values, $processor->getFormValues());

	//process the form iff the corresponding post signal is present in $_POST
	$postSignal = $postSignals[$i];
	if(isset($_POST[$postSignal])) {
		$processor->processForm();
		//store processor object and reload
		$_SESSION['processor'.$i] = $processor;
		header("Location: $thisPage");
		exit;
	}
}
?>