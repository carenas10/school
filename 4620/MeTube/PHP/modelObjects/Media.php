<?php
require_once Path::modelObjects().'Entity.php';
require_once Path::modelObjects().'Comment.php';

class Media extends Entity {
	private $SHORT_DESCRIPTION_LENGTH = 50;
	private $title;
	private $path;
	private $name;
	private $type;

	public function __construct(array $row) {
		parent::__construct($row);
		$this->title = $row['title'];
		$this->name = $row['id'].'.'.$row['extension'];
		$this->path = Path::media().$this->name;
		$this->type = $row['type'];
		$this->description = $row['description'];
		$this->shortDescription = substr($this->description, 0, $this->SHORT_DESCRIPTION_LENGTH)."...";
		$this->ownerID = $row['userID'];
	}
	
	/* accessors */
	public function getTitle() {
		return $this->title;
	}
	public function getDescription() {
		return $this->description;
	}
	public function getShortDescription() {
		return $this->shortDescription;
	}
	public function getOwnerID() {
		return $this->ownerID;
	}
	public function getName() {
		return $this->name;
	}
	public function getPath() {
		return $this->path;
	}
	public function getType() {
		return $this->type;
	}
	public function getComments() {
		$conn = Connection::conn();
		$sql = sprintf("select * from Comments where mediaID=%d order by timestamp desc",
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select comments query failed');
		}
		$comments = array();
		while($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
			$comments[] = new Comment($row);
		}
		return $comments;
	}
	
	/* mutators */
	public function addComment($comment, $userID) {
		return Comment::create($this->id, $userID, $comment);
	}
	public function delete() {
		//delete media entry
		//keywords will automatically delete by cascade relationship
		$conn = Connection::conn();
		$sql = sprintf("delete from Media where id='%d'", 
			mysql_real_escape_string($this->id));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('delete media query failed');
		}
		
		//delete file on server
		if(file_exists($this->path) && !unlink($this->path)) {
			//if deleting file failed, create an exception and log it, but don't halt execution
			$exc = new ServerFailedException(sprintf('could not delete media %s for deleted user account.', $this->path));
			Log::logException($exc);
		}
	}
	
	/* static functions */
	public static function fromID($mediaID) {
		if(!(is_int($mediaID) || is_string($mediaID))) {
			throw new InvalidArgumentException();
		}
		$conn = Connection::conn();
		$sql = sprintf("select * from Media where id='%d'", 
			mysql_real_escape_string($mediaID));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('select media query failed');
		}
		if(!($row = mysql_fetch_array($retval, MYSQL_ASSOC))) {
			//no media with $mediaID found
			return false;
		}
		//construct and return media
		return new Media($row);
	}
	public static function create($title, $description, array $keywords, $userID,
		$category, $extension, $type, $tmpPath) {
		//insert media entry
		$conn = Connection::conn();
		$sql = sprintf("insert into Media (title, description, userID, category, extension, type)".
			"values ('%s', '%s', %d, '%s', '%s', '%s')",
			mysql_real_escape_string($title),
			mysql_real_escape_string($description),
			mysql_real_escape_string($userID),
			mysql_real_escape_string($category),
			mysql_real_escape_string($extension),
			mysql_real_escape_string($type));
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('inserting media sql entry failed');
		}
		$mediaID = mysql_insert_id();
		
		//insert keyword entries
		foreach($keywords as $keyword) {
			$sql = sprintf("insert into MediaKeywords (mediaID, keyword) values (%d, '%s')",
				mysql_real_escape_string($mediaID),
				mysql_real_escape_string($keyword));
			$retval = mysql_query($sql, $conn);
			if(!$retval) {
				//clean up sql media entry and throw exception
				$sql = sprintf("delete from Media where id='%d'", 
					mysql_real_escape_string($mediaID));
				mysql_query($sql, $conn);
				throw new sqlException('insert media keyword query failed');
			}
		}
		
		//finally, upload file
		$media = Media::fromID($mediaID);
		$path = $media->getPath();
		if(file_exists($path)) {
			$sql = sprintf("delete from Media where id='%d'", 
				mysql_real_escape_string($mediaID));
			mysql_query($sql, $conn);
			throw new InvalidStateException('Uploaded file already exists. MediaID conflict');
		}
		//try to move file from temp dir to permanent dir
		if(!move_uploaded_file($tmpPath, $path)) {
			//clean up sql entries and throw exception
			$sql = sprintf("delete from Media where id='%d'", 
				mysql_real_escape_string($mediaID));
			mysql_query($sql, $conn);
			throw new ServerFailedException('Could not move uploaded file out of temporary directory.');
		}

		//return id of just-inserted media
		return $mediaID;
	}
	//Get array of all possible categories for a media
	//e.g. Gaming, Entertainment, Blogs, etc.
	public static function getCategories() {
		$conn = Connection::conn();
		$sql = "select COLUMN_TYPE from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'Media' and COLUMN_NAME = 'category'";
		$retval = mysql_query($sql, $conn);
		if(!$retval) {
			throw new sqlException('get categories query failed');
		}
		$row = mysql_fetch_array($retval);
		$categories = str_replace("'", "", substr($row['COLUMN_TYPE'], 5, (strlen($row['COLUMN_TYPE'])-6)));
		$categories = explode(",", $categories);
		return $categories;
	}
}
?>