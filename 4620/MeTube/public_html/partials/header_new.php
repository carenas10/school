<div id="leftHead" class="alpha grid_6">
    <h1><a href="index.php" style="text-decoration:none; color: inherit;">
        <span class="red">Me</span>Tube<span class="red">.</span>
    </a></h1>
    <ul>
    	<li><a href="playlists.php" class="headLink" style="text-decoration:none">Playlists</a></li>
    	<li><a href="subscriptions.php" class="headLink" style="text-decoration:none">Subscriptions</a></li>
        <li><a href="favorites.php" class="headLink" style="text-decoration:none">Favorites</a></li>
        <li><a href="accounts.php" class="headLink" style="text-decoration:none">Users</a></li> 
    </ul>
</div>
<div id="rightHead" class="grid_6 omega">
	
        <!-- If logged in, show account button -->
        <?php if(isset($_SESSION['userID'])): ?>
            <div id="upperRightHead">
            	<a href="upload.php" class="headLink">Upload</a> | 
            	<a href="inbox.php" class="headLink">Inbox</a> | 
                <a href="myAccount.php" class="headLink">My Account</a> | 
                <form method="post" action="<?php $thisPage;?>" style="display:inline;">
                    <input class="linkButton" type="submit" name="logout" value="Log Out">
                </form>
            </div>
        <!-- Not Logged in. Show register and login info -->
        <?php else: ?>
            <p id="upperRightHead">
                <a href="login.php" class="headLink"><strong>Log In</strong></a> |
                <a href="register.php" class="headLink"><strong>Register</strong></a>
                <br />
                Become a member to upload and share!
            </p>
        <?php endif; ?>

    <form method="get" action="search">
    	<input type="text" name="searchQuery" value="<?php if(isset($searchQuery)) echo $searchQuery;?>" />
    	<input type="submit" class="search_button" value="search" />
    </form>
</div>
<hr />