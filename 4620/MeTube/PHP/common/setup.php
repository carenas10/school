<?php
require Path::php().'SessionManager.php';
require_once Path::php().'Log.php';
require_once Path::modelObjects().'Account.php';
SessionManager::startSession();

//holds the url referencing current page, including get parameters
$thisPage = basename($_SERVER['REQUEST_URI']);

//handle exceptions with handleException function
function handleException(Exception $e) {
	//log exceptions and redirect to serverError page
	Log::logException($e);
	require Path::errors().'serverError.php';
	exit;
}
set_exception_handler('handleException');

//Log out if user requested to
if(isset($_SESSION['userID']) && isset($_POST['logout'])) {
	$_SESSION = array();
	session_destroy();
	//reload page to avoid "resend data" messages on user reload
	header("Location: $thisPage");
	exit;
}

//$_SESSION['desiredPage'] holds the page the that login should redirect to after
//logging in. If a user navigates away from login page, we must clear this variable.
if(isset($_SESSION['desiredPage']) && $thisPage != 'login') {
	unset($_SESSION['desiredPage']);
}

//get account if user is logged in
if(isset($_SESSION['userID'])) {
	$myAccount = Account::fromID($_SESSION['userID']);
	//if no account found redirect to login
	//handles the case where a user is logged in on multiple tabs/windows/devices
	//and the account gets deleted in one tab/window/device
	if(!$myAccount) {
		$_SESSION = array();
		session_destroy();
		header("Location: login");
		exit;
	}
}
?>