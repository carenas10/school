<?php
require_once Path::modelObjects().'Media.php';
require_once Path::modelObjects().'ModelObject.php';

class Browser extends ModelObject {
	private $resultsPerPage = 10;
	private $category = 'Any';
	private $page = 1;

	public function __construct($category = 'Any', $page = 1) {
		//validate arguments before setting corresponding instance vars
		if(in_array($category, Media::getCategories())) {
			$this->category = $category;
		}
		if(intval($page) >= 1 && intval($page) <= $this->getNumPages()) {
			$this->page = $page;
		}
	}
	
	public function getPage() {
		return $this->page;
	}
	public function getSelectedCategory() {
		return $this->category;
	}

	public function getTotalNumResults() {
		$conn = Connection::conn();
		if($this->category == 'Any') {
			$sql = "select count(*) as count from Media";
		} else {
			$sql = sprintf("select count(*) as count from Media where category='%s'",
				mysql_real_escape_string($this->category));
		}
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('count num browse results failed');
		}
		$row = mysql_fetch_array($retval, MYSQL_ASSOC);
		return intval($row['count']);
	}
	
	public function getNumPages() {
		return intval(ceil($this->getTotalNumResults()/$this->resultsPerPage));
	}

	public function getResults() {
		$conn = Connection::conn();
		if($this->category == 'Any') {
			$sql = sprintf("select * from Media order by id limit %d,%d",
				mysql_real_escape_string(($this->page-1)*$this->resultsPerPage),
				mysql_real_escape_string($this->resultsPerPage));
		} else {
			$sql = sprintf("select * from Media where category='%s' order by id limit %d,%d",
				mysql_real_escape_string($this->category),
				mysql_real_escape_string(($this->page-1)*$this->resultsPerPage),
				mysql_real_escape_string($this->resultsPerPage));
		}
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('get browse results query failed');
		}
		$results = array();
		while($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
			$results[] = new Media($row);
		}
		return $results;
	}
}
?>