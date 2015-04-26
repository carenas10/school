<?php
require_once '../Path.php';
require_once Path::modelObjects().'Searcher.php';
require Path::common().'setup.php';

if(isset($_GET['searchQuery'])) {
	$searcher = new Searcher();
	$searcher->search($_GET['searchQuery']);
	$searchQuery = $searcher->getSearchString();
	$results = $searcher->getResults();
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

			<?php
				if(isset($searchQuery)):
			
				echo sprintf("<h2>%d results found for '%s'</h2>", count($results), $searchQuery);
			
				foreach($results as $media) {
					$account = Account::fromID($media->getOwnerID());
			?>
				<div class="searchResultsBlock">
					<!-- TITLE -->
					<a href="media?mediaID=<?php echo $media->getID();?>" class="searchResult">
						<h2><?php echo $media->getTitle();?></h2>
					</a>

					<!-- DESCRIPTION --> 
					<p>Description: <?php echo $media->getShortDescription();?></p>
					
					<!-- USER -->
					Uploaded By: 
					<a href="<?php echo 'account?accountID='.$account->getID();?>">
						<?php echo $account->getUsername();?>
					</a>
				</div>

			<?php } endif; ?>
        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>

</body>
</html>