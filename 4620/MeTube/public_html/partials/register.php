<?php
    require_once '../Path.php';
    require_once Path::formProcessors().'RegistrationProcessor.php';
    require Path::common().'setup.php';
    
    $processorClasses = array('RegistrationProcessor');
    $postSignals = array('registerUser');

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
            <?php if(isset($msg['registrationSuccessful'])): ?> <!-- registration successful --> 
                <h3 id="registrationSuccessfulMsg">Registration successful! You are now logged in to your account. </h3>
                Have a
                <a href="myAccount" id="linkToYourAccount">
                link to your account
                </a>

            <?php elseif(isset($myAccount)): ?> <!-- user logged in -->
                You are already logged in. To register, first
                <form method="post" action="<?php echo $thisPage;?>">
                    <input type="submit" name="logout" value="log out">
                </form>
            <?php else: ?> <!-- user needs to register -->
                <h1>Register</h1>
                <?php
                    if(isset($msg['usernameEmpty'])) {
                        echo '<h6 id="usernameEmptyMsg">Username required.</h6>';
                    }
                    if(isset($msg['usernameTooLong'])) {
                        echo '<h6 id="usernameTooLongMsg">Username is too long.</h6>';
                    }
                    if(isset($msg['usernameContains@Symbol'])) {
                        echo '<h6 id="usernameContainsAtSymbolMsg">Your username cannot contain the @ symbol.</h6>';
                    }
                    if(isset($msg['usernameTaken'])) {
                        echo '<h6 id="usernameTakenMsg">Username is already taken.</h6>';
                    }
                    if(isset($msg['emailTooLong'])) {
                        echo '<h6 id="emailTooLongMsg">Email is too long.</h6>';
                    }
                    if(isset($msg['emailInvalid'])) {
                        echo '<h6 id="emailInvalidMsg">Please enter a valid email address.</h6>';
                    }
                    if(isset($msg['emailTaken'])) {
                        echo '<h6 id="emailTakenMsg">Email is already taken.</h6>';
                    }
                    if(isset($msg['passwordEmpty'])) {
                        echo '<h6 id="passwordEmptyMsg">Password is required.</h6>';
                    }
                    if(isset($msg['passwordsDoNotMatch'])) {
                        echo '<h6 id="passwordsDoNotMatchMsg">The specified passwords to not match.</h6>';
                    }
                ?>
                <form method="post" action="<?php echo $thisPage;?>">   
                    <label for="username">Choose a Username: </label>
                    <input type="text" class="contentInput" name="username" value="<?php echo $values['username']?>"> <br /><br />

                    <label for="email">Your Email: </label>
                    <input type="text" class="contentInput" name="email" value="<?php echo $values['email']?>"> <br /><br />
    
                    <label for="password">Choose a Password: </label>
                    <input type="password" class="contentInput" name="password"> <br /><br />

                    <label for="confirmPassword">Confirm Password: </label>
                    <input type="password" class="contentInput" name="confirmPassword"> <br /> <br />
                    
                    <input type="submit" class="contentSubmit" name="registerUser" value="register">
                </form>

            <?php endif; ?>

        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>
</body>
</html>