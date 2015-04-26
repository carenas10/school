<?php
	require_once '../Path.php';
	require_once Path::formProcessors().'NewPlaylistProcessor.php';
	require_once Path::formProcessors().'DeletePlaylistProcessor.php';
	require_once Path::formProcessors().'RemovePlaylistMediaProcessor.php';
	require Path::common().'setup.php';

	require Path::common().'redirectGuestToLogin.php';

	$processorClasses = array('NewPlaylistProcessor', 'DeletePlaylistProcessor', 'RemovePlaylistMediaProcessor');
	$postSignals = array('createNewPlaylist', 'deletePlaylist', 'removeMedia');

	require Path::common().'formHandlerCode.php';

	$playlists = $myAccount->getPlaylists();
?>
<html>
<head>
    <title></title>
    <link rel="stylesheet" href="css/reset.css" />
    <link rel="stylesheet" href="css/text.css" />
    <link rel="stylesheet" href="css/960_12_col.css" />
    <link rel="stylesheet" href="css/newstyle.css" />
</head>
<body>
    <!-- container is a wrapper for all main sections, and defines bounds of
    any content on the screen -->
    <div id="container" class="container_12">

    	<!-- IMPORT HEADER -->
    	<?php require_once Path::partials().'header_new.php' ?>

        <!-- CONTENT REGION -->
        <div id="content" class="grid_12" style="text-align: center">
        	<!--Case 1: No Playlists--> 	
    		<?php if(count($playlists) == 0): ?>
				<h2 id="noPlaylistsMsg">You have no playlists.</h2>

			<?php
				//case 2: user has playlists
				else:
				echo '<h2>Your Playlists</h2>';

				//show existing playlists
				foreach($playlists as $playlist) {
			?>
				<div class="playlist" style="background-color: white; margin-bottom: 20px; padding: 5px; padding: 0 0 10 0; border-bottom: 2px solid #cccccc;">
					<h3 class="playlistName" style="width:100%; background-color:#EE3B34; color: white;">
						<?php echo $playlist->getName();?>
					</h3>

					<?php
					foreach($playlist->getMedia() as $media) {
					?>
						<div class="playlistItem" style="border-bottom: 1px solid #cccccc; padding-bottom: 5px; margin-bottom: 10px;">
							<a href="media?mediaID=<?php echo $media->getID();?>&playlistID=<?php echo $playlist->getID();?>">
								<h4 class="playlistItemTitle" style="margin-bottom: 10px;"><?php echo $media->getTitle();?></h4>
							</a>
							<form method="post" action="<?php echo $thisPage;?>">
								<input type="hidden" name="playlistID" value="<?php echo $playlist->getID();?>">
								<input type="hidden" name="mediaID" value="<?php echo $media->getID();?>">
								<input type="submit" name="removeMedia" value="remove">
							</form>
						</div>
					<?php
					}
					?>
					<form method="post" action="<?php echo $thisPage;?>">
						<input type="hidden" name="playlistID" value="<?php echo $playlist->getID();?>">
						<input type="submit" name="deletePlaylist" class="contentSubmit" value="delete playlist">
					</form>
				</div>
			<?php 
				} 
				endif;

				//create new playlist
				if(isset($msg['playlistNameEmpty'])) {
					echo '<h3 id="playlistNameEmptyMsg">Playlist name is empty.</h3>';
				}
				if(isset($msg['playlistNameTooLong'])) {
					echo '<h3 id="playlistNameTooLongMsg">Playlist name is too long.</h3>';
				}
			?>

			<form method="post" action="<?php echo $thisPage;?>">
				New Playlist: <input type="text" name="newPlaylistName">
				<input type="submit" name="createNewPlaylist" value="create playlist">
			</form>

        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>
</body>
</html>