<?php
    require_once '../Path.php';
    require Path::common().'setup.php';

    //redirect guest to login only if his/her account was not just deleted
    if(!isset($_GET['accountDeleted'])) {
        require Path::common().'redirectGuestToLogin.php';
        
        if(isset($_POST['deleteAccount'])) {
            $myAccount->delete();
            SessionManager::destroySession();
            header("Location: $thisPage?accountDeleted=true");
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
            <!-- Account just deleted --> 
            <?php if(!isset($myAccount) && isset($_GET['accountDeleted'])): ?>
                <h1 id="accountDeletedMsg">Account deleted.</h1>

            <!-- Normal View--> 
            <?php else: ?>
                <h1>Welcome to your account, <?php echo $myAccount->getUsername();?>!</h1>
                Username: <?php echo $myAccount->getUsername();?> <br /> <br />
                Email: <?php echo $myAccount->getEmail();?> <br /> <br />
                <a href="inbox" style="font-size: 16px">My Inbox</a><br /><br />
                <form method="post" action="editAccount" style="display: inline">
                    <input class="contentSubmit" type="submit" name="editAccount" value="Edit Account" >
                </form>
                <form method="post" action="<?php echo $thisPage;?>" onsubmit="return confirm('Are you sure you want to delete your account and videos forever? THIS CANNOT BE UNDONE.')" style="display: inline">
                    <input class="contentSubmit" type="submit" name="deleteAccount" value="Delete Account">
                </form>

            <?php endif; ?>
        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>
</body>
</html>