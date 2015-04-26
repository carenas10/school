<?php
require_once Path::php().'exceptions.php';
require_once Path::php().'Connection.php';
/*
	ModelObject is the superclass for all model objects.
	
	1) A model object contains logic and data, but not presentation code.
	2) Model objects will never have any reference to html.
	3) All database calls should be made within model objects (with few exceptions).
	4) The ModelObject superclass is intentionally sparse because most model objects do not
		share much functionality. The class is intended primarily to distinguish at a
		glance between a model object and a non-model object.
*/
abstract class ModelObject {
	//intentionally empty
}
?>