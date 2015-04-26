<?php
    require_once '../Path.php';
    require_once Path::formProcessors().'LoginProcessor.php';
    require_once Path::formProcessors().'ResetPasswordProcessor.php';
    require Path::common().'setup.php';

    $processorClasses = array('ResetPasswordProcessor');
    $postSignals = array('resetPassword');

    require Path::common().'formHandlerCode.php';

    if(isset($msg['passwordReset'])) {
    	$_SESSION['userID'] = $msg['userID'];
    }

    $validAttempt = ResetPasswordProcessor::isValidResetAttempt();
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
            //case 1: successfully changed password
            if(isset($msg['passwordReset'])):
            ?>
            <h3>Password successfully changed!</h3>
            
            <!-- INVALID ATTEMPT -->
            <?php elseif(!$validAttempt): ?>
            <h3>This link is invalid.</h3> 
            <p>You either waited too long to follow the reset link or your password has already been reset.</p>
            <p>Retrieve another link from here: <a href="forgotPassword">forgot password</a></p>
        
            <!-- VALID ATTEMPT -->
            <?php else: ?>
            <h1>Enter your new password</h1>
            <?php
                if(isset($msg['passwordEmpty'])) {
                    echo '<h6 id="passwordEmptyMsg">Password is required.</h6>';
                }
                if(isset($msg['passwordsDoNotMatch'])) {
                    echo '<h6 id="passwordsDoNotMatchMsg">The specified passwords to not match.</h6>';
                }
            ?>
            <form method="post" action="<?php echo $thisPage;?>">
                <label for="password">New Password: </label>
                <input type="password" name="password" class="contentInput"> <br /><br />

                <label for="confirmPassword">Confirm: </label>
                <input type="password" name="confirmPassword" class="contentInput"> <br /><br />
                
                <input type="submit" name="resetPassword" class="contentSubmit  " value="Change password">
            </form>
            <?php endif; ?>
        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>
</body>
</html>
