<?php
require_once Path::modelObjects().'ModelObject.php';
require_once Path::modelObjects().'Media.php';

class Searcher extends ModelObject {
	//the input string
	private $searchString;
	
	//the input string divided into tokens
	private $searchTokens;
	
	//Media results
	private $results;
	
	//find all media with part of the title or description matching at least one search token
	//or with at least one entire keyword matching at least one search token
	public function search($searchString) {
		if(!is_string($searchString))
			throw new InvalidArgumentException();
		$searchString = trim(htmlspecialchars($searchString));
		$this->searchString = $searchString;
		
		//filter explode result to keep out empty strings
		$this->searchTokens = array_filter(explode(' ', $searchString));
		
		$this->results = array();
		
		//match keywords
		//store media ID's with mediaID as key and boolean true as value
		//with this method, no mediaID can be put into mediaIDs more than once
		$mediaIDs = array();
		foreach($this->searchTokens as $token) {
			$conn = Connection::conn();
			//match keywords
			//token must match whole keyword
			$escToken = mysql_real_escape_string($token);
			$sql = sprintf("select distinct mediaID from MediaKeywords where ".
				"keyword rlike ' %s ' or keyword rlike ' %s$' or keyword rlike '^%s ' or keyword rlike '^%s$'",
				$escToken, $escToken, $escToken, $escToken);
			$retval = mysql_query($sql, $conn);
			if(!$retval) {
				throw new sqlException('select mediaID from keyword query failed');
			}
			while($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
				$mediaIDs[$row['mediaID']] = true;
			}
		}
		
		//match title or description
		foreach($this->searchTokens as $token) {
			//token must match whole word in title or description
			$sql = sprintf("select id from Media where ".
				"title rlike ' %s ' or title rlike ' %s$' or title rlike '^%s ' or title rlike '^%s$' or ".
				"description rlike ' %s ' or description rlike ' %s$' or description rlike '^%s ' or description rlike '^%s$'",
				$escToken, $escToken, $escToken, $escToken,
				$escToken, $escToken, $escToken, $escToken);
			$retval = mysql_query($sql, $conn);
			if(!$retval) {
				throw new sqlException('select media matching search query failed');
			}
			while($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
				$mediaIDs[$row['id']] = true;
			}
		}
		
		//convert IDs to media
		foreach($mediaIDs as $mediaID => $dummy) {
			$sql = sprintf("select * from Media where id='%s'",
				mysql_real_escape_string($mediaID));
			$retval = mysql_query($sql, $conn);
			if(!$retval) {
				throw new sqlException('select media from mediaID failed');
			}
			$row = mysql_fetch_array($retval, MYSQL_ASSOC);
			if(!$row) {
				$e = new InternalConsistencyException('found mediaID in MediaKeywords with no matching media item');
				Log::logException($e);
			} else {
				$this->results[] = new Media($row);
			}
		}
	}
	
	public function getSearchString() {
		return $this->searchString;
	}
	
	//returns results in no particular order
	public function getResults() {
		return $this->results;
	}
}
?>