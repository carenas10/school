<?php
    require_once '../Path.php';
    require_once Path::formProcessors().'EditAccountProcessor.php';
    require Path::common().'setup.php';

    require Path::common().'redirectGuestToLogin.php';
    
    //redirect to myAccount to cancel changes
    if(isset($_POST['cancelChangesToAccount'])) {
        header("Location: myAccount");
        exit;
    }

    $processorClasses = array('EditAccountProcessor');
    $postSignals = array('saveChangesToAccount');
    
    require Path::common().'formHandlerCode.php';
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
            <h1>Edit your account</h1>
            <?php
                if(isset($msg['updateSuccessful'])) {
                    echo '<h3 id="updateSuccessfulMsg">Update successful.</h3>';
                }
                if(isset($msg['usernameEmpty'])) {
                    echo '<h3 id="usernameEmptyMsg">Username required.</h3>';
                }
                if(isset($msg['usernameTooLong'])) {
                    echo '<h3 id="usernameTooLongMsg">Username is too long.</h3>';
                }
                if(isset($msg['usernameContains@Symbol'])) {
                    echo '<h3 id="usernameContainsAtSymbolMsg">Your username cannot contain the @ symbol.</h3>';
                }
                if(isset($msg['usernameTaken'])) {
                    echo '<h3 id="usernameTakenMsg">Username is already taken.</h3>';
                }
                if(isset($msg['emailTooLong'])) {
                    echo '<h3 id="emailTooLongMsg">Email is too long.</h3>';
                }
                if(isset($msg['emailInvalid'])) {
                    echo '<h3 id="emailInvalidMsg">Please enter a valid email address.</h3>';
                }
                if(isset($msg['emailTaken'])) {
                    echo '<h3 id="emailTakenMsg">Email is already taken.</h3>';
                }
            ?>

            <!-- The onkeypress event is a javascript event to prevent submission of the
            form upon an Enter press. Since there are two submit inputs, cancel and
            save, it is ambiguous (from user perspective) which should be submitted
            when pressing Enter. Since cancel comes first in the html, cancel is
            actually the input submitted, which is not what we want. Thus onkeypress.
            -->

            <form method="post" action="<?php echo $thisPage;?>" onkeypress="return event.keyCode != 13;">
                Username: <input type="text" class="contentInput" name="username" value="<?php echo $values['username'];?>"> <br /> <br />
                Email: <input type="text" class="contentInput" name="email" value="<?php echo $values['email'];?>"> <br /> <br />
                Password: <input type="password" class="contentInput" name="password" placeholder="Enter new password"> <br /> <br />
                <input type="submit" class="contentSubmit" name="cancelChangesToAccount" value="cancel">
                <input type="submit" class="contentSubmit" name="saveChangesToAccount" value="save">
            </form>

        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>
</body>
</html>