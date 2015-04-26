<?php
/*
	A common class for obtaining paths to files.
*/
class Path {
	static public function externalRoot() {
		return 'people.cs.clemson.edu/~jacksod/';
	}

	static public function base() {
		return '/home/jacksod/';
	}

	static public function php() {
		return Path::base().'PHP/';
	}
	
	static public function common() {
		return Path::base().'PHP/common/';
	}
	
	static public function formProcessors() {
		return Path::base().'PHP/formProcessors/';
	}
	
	static public function modelObjects() {
		return Path::base().'PHP/modelObjects/';
	}

	static public function publicHTML() {
		return Path::base().'public_html/';
	}
	
	static public function partials() {
		return Path::base().'public_html/partials/';
	}
	
	static public function errors() {
		return Path::base().'public_html/errors/';
	}
	
	static public function media() {
		return Path::base().'mediaFiles/';
	}
}
?>
