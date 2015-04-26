<?php
	require_once '../Path.php';
	require Path::common().'setup.php';

	require Path::common().'redirectGuestToLogin.php';

	//remove requested media from favorites 
	if(isset($_POST['unfavorite'])) {
		$myAccount->unfavorite($_POST['mediaID']);
		header("Location: $thisPage");
		exit;
	}

	$favorites = $myAccount->getFavorites();
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
			<!-- NO FAVORITES -->
			<?php if(count($favorites) == 0): ?>
			<h2 id="noFavoritesMsg">You have no favorites.</h3>

			<!-- USER HAS FAVORITES -->
			<?php 
			else:
				echo '<h2>Your Favorites</h2>';
				foreach($favorites as $media) {
					$account = Account::fromID($media->getOwnerID());
			?>
				<div class="favoritesBlock">
					<!-- TITLE -->
					<a href="media?mediaID=<?php echo $media->getID();?>">
						<h2 class="favoriteItemTitle"><?php echo $media->getTitle();?></h2>
					</a>

					<!-- DESCRIPTION --> 
					<p>Description: <?php echo $media->getShortDescription();?></p>
					
					<!-- USER -->
					Uploaded By: 
					<a href="<?php echo 'account?accountID='.$account->getID();?>">
						<?php echo $account->getUsername();?>
					</a> <br /><br />

					<!-- REMOVE -->
					<form method="post" action="<?php echo $thisPage;?>">
						<input type="hidden" name="mediaID" value="<?php echo $media->getID();?>">
						<input type="submit" name="unfavorite" class="contentSubmit" value="remove from favorites">
					</form>
				</div>

			<?php } endif; ?>
        </div> <!-- End Content -->
        
        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>

		
</body>
</html>