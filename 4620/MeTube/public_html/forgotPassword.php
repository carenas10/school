<?php
    require_once '../Path.php';
    require_once Path::formProcessors().'LoginProcessor.php';
    require_once Path::formProcessors().'ForgotPasswordProcessor.php';
    require Path::common().'setup.php';

    $processorClasses = array('ForgotPasswordProcessor');
    $postSignals = array('sendResetPasswordLink');

    require Path::common().'formHandlerCode.php';

    //if you got here from login page after failed login, login page should provide
    //the username or email in get parameter
    if(!empty($_GET['user'])) {
        $values['email'] = $_GET['user'];
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

            <!-- case 1: just sent reset password email -->
            <?php if(isset($msg['sentResetPasswordLink'])): ?>
            <h3>A link to reset your password has been emailed to you. Please follow the link within 15 minutes.</h3>
            
            <!-- case 2: user unfound -->
            <?php elseif(isset($msg['userUnfound'])): ?>
            <h3>The account with that email could not be found.</h3>
        
            <!-- case 3: need to send reset password email -->
            <?php else: ?>
                <h1>Forgot your password?</h1>
                <?php
                    if(isset($msg['emailUsernameTooLong'])) {
                        echo '<h6 id="emailUsernameTooLongMsg">Your email or username is too long.</h6>';
                    }
                ?>
                <form method="post" action="forgotPassword">
                    <label for="email">Email or Username:</label>
                    <input type="text" class="contentInput" name="email" value="<?php echo $values['email']?>"> 
                    <br /><br />
                    
                    <input type="submit" class="contentSubmit" name="sendResetPasswordLink" value="Submit">
                </form>
            
            <?php endif; ?>

        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>
</body>
</html>