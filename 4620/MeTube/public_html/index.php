<?php
	require_once '../Path.php';
	require_once Path::modelObjects().'Media.php';
	require_once Path::modelObjects().'Browser.php';
	require Path::common().'setup.php';

	$category = 'Any';
	$page = 1;
	if(isset($_GET['category'])) {
		$category = $_GET['category'];
	}
	if(isset($_GET['page'])) {
		$page = $_GET['page'];
	}
	//get browse results from Browser
	$browser = new Browser($category, $page);
	$selectedCategory = $browser->getSelectedCategory();
	$results = $browser->getResults();
	$numResults = $browser->getTotalNumResults();
	$numPages = $browser->getNumPages();
	$page = $browser->getPage();

	//get categories and add "Any" category
	$categories = Media::getCategories();
	array_unshift($categories, 'Any');

	//turn a page index into the url of that page
	function urlWithPage($index) {
		$params = $_GET;
		$params['page'] = $index;
		return sprintf("?%s", http_build_query($params));
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

        	<!-- ORGANIZE BY... -->
        	<fieldset class="alpha grid_4" style="border: 1px solid; padding: 5px; margin-top:10px; margin-right:0;">
			<form method="get" action="<?php echo $thisPage;?>">
				<label for="category">Organize by:</label>
				<select name="category"> 
					<?php
					foreach($categories as $category) {
						echo sprintf('<option value="%s" %s>%s</option>',
							$category,
							$selectedCategory==$category? 'selected="selected"' : '',
							$category);
					}
					?>
				</select><br />
				<input type="submit" class="contentSubmit" value="submit">
			</form>
			</fieldset>	

			<!-- SEARCH LISTINGS -->
			<div class="grid_8 omega" style="margin-left:0;">
				<?php
					//case 1: No results
					if($numResults == 0):
					echo '<h3 id="noResultsMsg">No results found</h3>';

					//case 2: Results
					else:
					foreach($results as $media) {
						$account = Account::fromID($media->getOwnerID());
				?>
					<div class="searchResultsBlock">
						<!-- TITLE -->
						<a href="media?mediaID=<?php echo $media->getID();?>">
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

				<?php
					}
					endif;
					
					if($page > 1) {
						echo sprintf('<a href="%s">previous</a>', urlWithPage($page-1));
					}
					echo "&nbsp;";
					if($page < $numPages) {
						echo sprintf('<a href="%s">next</a>', urlWithPage($page+1));
					}
				?>
			</div>

        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>
</body>
</html>