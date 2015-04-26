<?php
    require_once '../Path.php';
    require_once Path::modelObjects().'Inbox.php';
    require Path::common().'setup.php';

    require Path::common().'redirectGuestToLogin.php';

    $inbox = new Inbox($myAccount);
    $threads = $inbox->getThreads();
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
            <h1>Messages</h1>
            
            <?php
                foreach($threads as $thread) {
                $previewMessage = $thread->getMostRecentMessage();
                //get other person's account id from message
                //other person could be sender or recipient of the message
                if($previewMessage->getRecipientID() == $myAccount->getID()) {
                    $theirID = $previewMessage->getSenderID();
                } else {
                    $theirID = $previewMessage->getRecipientID();
                }
                $theirAccount = Account::fromID($theirID);
            ?>
                <div style="background-color: white; padding-top:10px;" class="grid_12"> <!-- Thread list item -->
                    <a href="<?php echo 'thread?threadID='.$thread->getID();?>">
                    <h4 class="threadUsername"><?php echo $theirAccount->getUsername();?></h4>
                    <p class="threadPreview" style="color: black;"><?php echo $previewMessage->getContent();?></p>
                    </a>
                </div>
                <hr class="grid_12" />
            <?php } ?>

            <a href="newMessage">Send new message</a>
            <br />
        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>
</body>
</html>