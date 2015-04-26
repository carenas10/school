<?php
	require_once '../Path.php';
	require Path::common().'setup.php';

	//if there is no passed accountID, redirect to accounts
	if(!isset($_GET['accountID'])) {
		header("Location: accounts");
		exit;
	}

	$accountID = $_GET['accountID'];
	$account = Account::fromID($accountID);

	//if you're looking at your own account, redirect to myAccount
	if(isset($myAccount) && $myAccount->getID() == $accountID) {
		header("Location: myAccount");
		exit;
	}

	if(isset($myAccount)) {
		if(isset($_POST['subscribe'])) {
			$myAccount->subscribe($accountID);
			header("Location: $thisPage");
			exit;
		}
		else if(isset($_POST['unsubscribe'])) {
			$myAccount->unsubscribe($accountID);
			header("Location: $thisPage");
			exit;
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
</head>
<body>
	<!-- container is a wrapper for all main sections, and defines bounds of
    any content on the screen -->
    <div id="container" class="container_12">

    	<!-- IMPORT HEADER -->
    	<?php require_once Path::partials().'header_new.php' ?>

        <!-- CONTENT REGION -->
        <div id="content" class="grid_12" style="text-align: center">

			<?php
			//case 1: account not found
			if(!$account):
				echo '<h3>The account could not be found.</h3>';
			//case 2: viewing someone else's account
			else:
				echo sprintf("<h2>This is %s's account.</h2>", $account->getUsername());
				
				if(isset($myAccount)) {
					//SUBSCRIBED.
					if($myAccount->isSubscribed($accountID)) { ?>
						<p>You are subscribed to this account.</p>
						<form method="post" action="<?php echo $thisPage; ?>">
							<input type="submit" name="unsubscribe" class="contentSubmit" value="Unsubscribe">
						</form>
					<?php
					} else { //NOT SUBSCRIBED.
					?>
						<form method="post" action="<?php echo $thisPage; ?>">
							<input type="submit" name="subscribe" class="contentSubmit" value="Subscribe">
						</form>
				<?php
					}
				}
				?>
			
			<?php
			endif;
			?>

        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>
		
</body>
</html>