<?php
    require_once '../Path.php';
    require_once Path::formProcessors().'LoginProcessor.php';
    require Path::common().'setup.php';

    $processorClasses = array('LoginProcessor');
	$postSignals = array('login');

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
        	<!--Logged In-->
        	<?php if(isset($myAccount)): ?>
	            <h1>You are logged in.</h1>
	            <form method="post" action="<?php $thisPage;?>">
	                <input class="contentSubmit" type="submit" name="logout" value="log out">
	            </form>
        
        	<!-- Not Logged In -->
            <?php else: ?>
        	<h1>Log In</h1>
            <?php //error messages
                if(isset($msg['emailUsernameTooLong'])) {
                    echo '<h6 id="emailUsernameTooLongMsg">Your email or username is too long.</h6>';
                }
                if(isset($msg['incorrectCredentials'])) {
                    echo '<span class="red"><h6 id="incorrectCredentialsMsg">Invalid login information.</h6></span>';
                }
            ?>

        	<form method="post" action="<?php echo $thisPage;?>">
   	        	<label for="email">Email or Username: </label>
	        	<input class="contentInput" type="text" name="email" value="<?php echo $values['email']?>" size="30" />	
	        	<br /><br />
   	     		<label for="password">Password: </label>
   	     		<input class="contentInput" type="password" name="password" size="30" /> 
                <br /><br />
   	     		<input class="contentSubmit" type="submit" name="login" value="Log In">
        	</form>

        	<br />
            <a href="register">Register</a> | 
            <a href="forgotPassword?user=<?php echo $values['email'];?>">I Forgot my Password</a>

            <?php endif; ?>

        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>
</body>
</html>