<?php
require_once '../Path.php';
require Path::common().'setup.php';

require Path::common().'redirectGuestToLogin.php';

$subscribedChannels = $myAccount->getSubscribedChannels();
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
        	<!-- NO SUBSCRIPTIONS -->
        	<?php if(count($subscribedChannels) == 0): ?>
				<h2 id="noSubscriptionsMsg">You have no subscriptions.</h2>

			<!-- USER HAS SUBSCRIPTIONS--> 
			<?php
			else:
			echo '<h2 id="yourSubscriptionsHeader">Your Subscriptions</h2>';

			foreach($subscribedChannels as $channel) { ?>
				<div style="background-color: white; margin-bottom: 20px; padding: 5px; padding: 0 0 10 0; border-bottom: 2px solid #cccccc;">
					<a href="">
					<?php echo "<a href=\"account?accountID=".$channel->getOwnerAccount()->getID()."\">"; ?>
						<h3 class="channelName" style="width:100%; background-color:#EE3B34; color: white;">
							<?php echo $channel->getOwnerAccount()->getUsername();?>
						</h3>
					</a>

					<?php
					foreach($channel->getMedia() as $media) {
					?>
						<div style="padding-bottom: 5px; margin-bottom: 10px;">
							<a href="media?mediaID=<?php echo $media->getID();?>">
								<h4 style="margin-bottom: 10px;"><?php echo $media->getTitle();?></h4>
							</a>
						</div>
					<?php } ?>
				</div>
			<?php }
			endif;
			?>

        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>
		
</body>
</html>