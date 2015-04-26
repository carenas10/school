<?php
if(!isset($myAccount)) {
	//store this page so login page can redirect here after logging in
	$_SESSION['desiredPage'] = $thisPage;
	header("Location: login");
	exit;
}
?>