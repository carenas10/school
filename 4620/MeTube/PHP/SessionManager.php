<?php
/*
	Description:
	This class will encapsulate starting and managing of all sessions. Right now the class
	does nothing but call session_start(), but if we ever add more secure session
	management, having all the logic in one place will be very useful.
*/
class SessionManager {
	static function startSession() {
		session_start();
	}
	
	static function destroySession() {
		// Unset all of the session variables.
		$_SESSION = array();

		// If it's desired to kill the session, also delete the session cookie.
		// Note: This will destroy the session, and not just the session data!
		if (ini_get("session.use_cookies")) {
			$params = session_get_cookie_params();
			setcookie(session_name(), '', time() - 42000,
				$params["path"], $params["domain"],
				$params["secure"], $params["httponly"]
			);
		}

		// Finally, destroy the session.
		session_destroy();
	}
}
?>