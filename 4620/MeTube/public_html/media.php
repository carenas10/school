<?php
	require_once '../Path.php';
	require_once Path::modelObjects().'Media.php';
	require_once Path::modelObjects().'Playlist.php';
	require_once Path::modelObjects().'Comment.php';
	require_once Path::modelObjects().'Playlist.php';
	require_once Path::modelObjects().'Downloader.php';
	require_once Path::formProcessors().'CommentProcessor.php';
	require_once Path::formProcessors().'AddToPlaylistProcessor.php';
	require Path::common().'setup.php';

	if(!isset($_GET['mediaID'])) {
		//redirect to homepage if there is no mediaID
		header("Location: index");
		exit;
	}

	$media = Media::fromID($_GET['mediaID']);

	$processorClasses = array('CommentProcessor', 'AddToPlaylistProcessor');
	$postSignals = array('submitNewComment', 'addToPlaylist');

	require Path::common().'formHandlerCode.php';

	//if comment was just posted, clear form value
	if(isset($msg['commentedSuccessfully'])) {
		$values['newCommentContent'] = '';
	}
	if(isset($_POST['download'])) {
		Downloader::download($media);
	}
	if(isset($_POST['favorite'])) {
		$myAccount->favorite($media->getID());
		header("Location: $thisPage");
		exit;
	}
	if(isset($_POST['unfavorite'])) {
		$myAccount->unfavorite($media->getID());
		header("Location: $thisPage");
		exit;
	}
	if($media and isset($myAccount)) {
		$isFavorite = $myAccount->isFavorite($media->getID());

		//if in playlist
		if(isset($_GET['playlistID']) && ($playlist = Playlist::fromID($_GET['playlistID'])) &&
			$playlist->getUserID() == $myAccount->getID() && $playlist->containsMedia($media->getID())) {
			$playlistMedia = $playlist->getMedia();
		}
	}
?>

<html>	
<head>
	<title></title>
    <link rel="stylesheet" href="css/reset.css" />
    <link rel="stylesheet" href="css/text.css" />
    <link rel="stylesheet" href="css/960_12_col.css" />
    <link rel="stylesheet" href="css/newstyle.css" />

	<link href="//vjs.zencdn.net/4.12/video-js.css" rel="stylesheet">
	<script src="//vjs.zencdn.net/4.12/video.js"></script>
	<!-- Uncomment if you have trouble playing in IE -->
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
		
</head>
<body>

    <!-- container is a wrapper for all main sections, and defines bounds of
    any content on the screen -->
    <div id="container" class="container_12">

    	<!-- IMPORT HEADER -->
    	<?php require_once Path::partials().'header_new.php' ?>

        <!-- CONTENT REGION -->
        <div id="content" class="grid_12" style="text-align: center">

        	<!-- MEDIA NOT FOUND -->
			<?php if(!$media): ?>
				<h3>The media could not be found.</h3>

			<!-- MEDIA FOUND--> 
			<?php else: ?>
				<h2 id="mediaTitle"><?php echo $media->getTitle();?></h2>
				
				<!-- MEDIA IS IMG -->
				<?php if($media->getType() == 'image') { ?>
					<img style="margin:0 auto; max-width: 940px" src="mediaFile?name=<?php echo $media->getName();?>&type=image" />
				
				<!-- MEDIA IS AUDIO -->
				<?php } else if($media->getType() == 'audio') { ?>
					<audio controls preload="auto" style="margin:0 auto;">
						<source src="mediaFile?name=<?php echo $media->getName();?>&type=audio" type="audio/mpeg">
						Your browser does not support the audio element.
					</audio> 

				<!-- MEDIA IS VIDEO -->
				<?php } else if($media->getType() == 'video') { ?>
					<video style="margin:0 auto;" id="example_video_1" class="video-js vjs-default-skin" controls preload="auto" width="720" height="480"
					poster="images/bluebox.jpg"
					data-setup="{}">
						<source src="mediaFile?name=<?php echo $media->getName();?>&type=video" type='video/mp4' />
						<p class="vjs-no-js">To view this video please enable JavaScript, and consider upgrading to a web browser that <a href="http://videojs.com/html5-video-support/" target="_blank">supports HTML5 video</a></p>
					</video>
				<?php } ?>

				<!--DOWNLOAD LINK-->
				<br /><br />
				<form style="display:inline;" method="post" action="<?php echo $thisPage;?>">
					<input style="display:inline;" type="submit" name="download" class="contentSubmit" value="Download">
				</form>

				<!-- FAVORITE BUTTON --> 
				<?php
				if(isset($myAccount)) {
				?>
				<form style="display:inline;" method="post" action="<?php echo $thisPage;?>">
					<?php
					if($isFavorite) {
						echo '<input type="submit" style="display:inline;" name="unfavorite" class="contentSubmit" value="Unfavorite">';
					} else {
						echo '<input type="submit" style="display:inline;" name="favorite" class="contentSubmit" value="Favorite">';
					}
					?>
				</form>
				<br /><br /><hr />

				<?php
					$playlists = $myAccount->getPlaylists();
					if(isset($msg['playlistDoesNotExist'])) {
						echo '<h3 id="playlistDoesNotExistMsg">The selected playlist does not exist.</h3>';
					}
					if(isset($msg['mediaAlreadyInPlaylist'])) {
						echo '<h3 id="mediaAlreadyInPlaylistMsg">The media is already in this playlist.</h3>';
					}
					if(count($playlists) > 0) {
					?> 
					<form method="post" action="<?php echo $thisPage;?>">
						<select style="font-size:14px;" name="playlistID">
							<?php
							foreach($playlists as $playlist) {
								//add checkmark to playlists media is a member of (&#x2713; is checkmark)
								//automatically select whichever element is passed from processor object
								echo sprintf('<option value="%d" %s>%s %s</option>',
									$playlist->getID(),
									$playlist->getID()==$values['playlistID']? 'selected="selected"':'',
									$playlist->getName(),
									$playlist->containsMedia($_GET['mediaID'])? '&#x2713;':'');
							}
							?>
						</select>
						<input type="submit" name="addToPlaylist" style="border-radius:0; border: 0; padding: 5px; background-color: #EE3B34; color:white; font-size:14px;" value="Add to Playlist">
					</form>
					<br /><hr />
				<?php } //if playlists  > 0
				} //if account 
				
				//if in playlist
				if(isset($playlistMedia)) {
					echo sprintf('<h4>Playlist: %s</h4>', $playlist->getName());
					foreach($playlistMedia as $playlistMediaItem) {
						//highlight the current media item
						echo sprintf('<a href="media?mediaID=%d&playlistID=%d">',
							$playlistMediaItem->getID(), $playlist->getID());
						if($playlistMediaItem->getID() == $media->getID()) {
							echo sprintf('<h5 style="color:red">%s</h5>', $playlistMediaItem->getTitle());
						} else {
							echo sprintf('<h5>%s</h5>', $playlistMediaItem->getTitle());
						}
						echo '</a>';
					}
				}
				?>
				
				<?php
				if(isset($msg['commentEmpty'])) {
					echo '<h3 id="commentEmptyMsg">Your comment is empty.</h3>';
				}
				if(isset($msg['commentTooLong'])) {
					echo '<h3 id="commentTooLongMsg">Your comment is too long.</h3>';
				}
				//only show comment form if user is logged in
				if(isset($myAccount)) {
				?>
					<form style="margin-top: 10px;" method="post" action="<?php echo $thisPage;?>">
						<textarea style="font-size: 14px;" cols="65" rows="8" name="newCommentContent"><?php echo $values['newCommentContent'];?></textarea><br /><br />
						<input type="submit" name="submitNewComment" class="contentSubmit" value="Comment">
					</form>
					<br />
				<?php
				}
				?>
				
				<?php
				//comments
				$comments = $media->getComments();
				echo "<h3>Comments</h3>";
				foreach($comments as $comment) {
					$commenterAccount = Account::fromID($comment->getCommenterID());
				?>
					<div style="background-color: white; border-bottom: 2px solid #cccccc; margin-bottom:5px; width: 50%; margin: 0 auto 5 auto;" >
						<a href="<?php echo 'account?accountID='.$commenterAccount->getID();?>">
							<span class="red commenterUsername"><p><?php echo $commenterAccount->getUsername();?></p></span>
						</a>
						<p class="commentContent"><?php echo $comment->getContent();?></p>
					</div>
				<?php
				}
				?>
				
			<?php endif; ?>
        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>

</body>
</html>