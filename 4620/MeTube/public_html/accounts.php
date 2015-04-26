<?php
require_once '../Path.php';
require Path::common().'setup.php';

$accounts = Account::getAllAccounts();
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

			<h1>Accounts</h1>
        	<?php
			foreach($accounts as $account) {
			?>
				<h3>
					<a class="accountName" href="<?php echo 'account?accountID='.$account->getID();?>">
					<?php echo $account->getUsername();?>
					</a>
				</h3>
			<?php
			}
			?>

        </div>

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>
</body>
</html>