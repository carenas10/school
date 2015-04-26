<?php
    require_once '../Path.php';
    require_once Path::formProcessors().'NewMessageProcessor.php';
    require Path::common().'setup.php';

    $processorClasses = array('NewMessageProcessor');
    $postSignals = array('submitNewMessage');

    require Path::common().'redirectGuestToLogin.php';
    require Path::common().'formHandlerCode.php';

    //redirect to new thread on message send
    if(isset($msg['messageSentSuccessfully'])) {
        header(sprintf("Location: thread?threadID=%s", $msg['threadID']));
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
            <h1>New Message</h1>
            <?php
            if(isset($msg['recipientEmpty'])) {
                echo '<h3 id="recipientEmptyMsg">No recipient specified.</h3>';
            }
            if(isset($msg['recipientDoesNotExist'])) {
                echo '<h3 id="recipientDoesNotExistMsg">The specified recipient does not exist.</h3>';
            }
            if(isset($msg['messageToSelf'])) {
                echo '<h3 id="messageToSelfMsg">You cannot send a message to yourself.</h3>';
            }
            if(isset($msg['contentEmpty'])) {
                echo '<h3 id="contentEmptyMsg">The message is empty.</h3>';
            }
            if(isset($msg['contentTooLong'])) {
                echo '<h3 id="contentTooLongMsg">The message is too long. Please shorten.</h3>';
            }
            ?>
            <form method="post" action="<?php echo $thisPage;?>">
                To: <input class="contentInput" type="text" name="messageRecipient" value="<?php echo $values['messageRecipient'];?>" placeholder="username or email"> <br /> <br />
                <textarea rows="4" name="messageContent" placeholder="Message..." style="font-size: 16px; width:75%"><?php echo $values['messageContent'];?></textarea>
                <br /><br />
                <input class="contentSubmit" type="submit" name="submitNewMessage" value="Send">
            </form>
            <br />
            <a href="inbox">Back to inbox</a>
            <br />
        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>
</body>
</html>