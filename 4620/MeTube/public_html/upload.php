<?php
    require_once '../Path.php';
    require_once Path::modelObjects().'Media.php';
    require_once Path::formProcessors().'UploadProcessor.php';
    require Path::common().'setup.php';

    $processorClasses = array('UploadProcessor');
    $postSignals = array('upload');

    require Path::common().'redirectGuestToLogin.php';
    require Path::common().'formHandlerCode.php';

    $categories = Media::getCategories();
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
            <!-- Upload Successful --> 
            <?php if(isset($msg['uploadSuccessful'])): ?>
                <h3 id="uploadSuccessfulMsg">Upload successful!</h3>
                <h3>Here is a <a href="media?mediaID=<?php echo $msg['mediaID'];?>">link to your media</a></h3>
            
            <!-- User is ready to upload -->
            <?php else: ?>
                <h1>Upload</h1>
            <?php
            if(isset($msg['noFileSelected'])) {
                echo '<h3 id="noFileSelectedMsg">No file selected.</h3>';
            }
            if(isset($msg['emptyTitle'])) {
                echo '<h3 id="titleEmptyMsg">Title is required.</h3>';
            }
            if(isset($msg['emptyDescription'])) {
                echo '<h3 id="descriptionEmptyMsg">Description is required.</h3>';
            }
            if(isset($msg['titleTooLong'])) {
                echo '<h3 id="titleTooLongMsg">Title is too long.</h3>';
            }
            if(isset($msg['descriptionTooLong'])) {
                echo '<h3 id="descriptionTooLongMsg">Description is too long.</h3>';
            }
            if(isset($msg['keywordTooLong'])) {
                echo '<h3 id="keywordTooLongMsg">At least one keyword is too long.</h3>';
            }
            if(isset($msg['fileTooLarge'])) {
                echo '<h3>The file is too large.</h3>';
            }
            if(isset($msg['invalidFileType'])) {
                echo '<h3>The file type is not one of the accepted types: ...</h3>';
            }
            ?>

            <form method="post" action="<?php echo $thisPage;?>" enctype="multipart/form-data">
                <h3>First, Pick a file...</h3>
                Supported file types: <br />
                Video: mp4 <br />
                Audio: mp3 <br />
                Image: png, jpg, gif <br /> <br />
                <input type="file" name="fileToUpload" accept="audio/mp3,video/mp4,image/*" />
                <br /><br />

                <h5>Now, tell us a little about it...</h5>
                <label for="title">Title</label>
                <input class="contentInput" type="text" name="title" value="<?php echo $values['title']?>">
                <br /><br />

                <label for="description">Description</label>
                <input class="contentInput" type="text" name="description" value="<?php echo $values['description']?>"> 
                <br /><br />

                <label for="category">Category</label>
                <select name="category"> 
                <?php
                foreach($categories as $category) {
                    echo sprintf('<option value="%s" %s>%s</option>',
                        $category,
                        $values['selectedCategory']==$category? 'selected="selected"' : '',
                        $category);
                }
                ?>
                </select><br><br>

                <label for="keywords">Keywords (separate by commas)</label>
                <input class="contentInput" type="text" name="keywords" value="<?php echo $values['keywords']?>">
                <br /><br />

                <input class="contentSubmit" type="submit" name="upload" value="Upload">
            </form>
            
            <?php endif; ?>
        </div> <!-- End Content -->

        <!-- IMPORT FOOTER -->
        <?php require_once Path::partials().'footer_new.php' ?>

    </div>
</body>
</html>