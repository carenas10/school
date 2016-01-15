<?php
    // LOGINS NOT SETUP
    // DELETES ID 5

    //define connection values
    include 'config.php';

    $connection = mysqli_connect($DBServer,$DBUser,$DBPass,$DBName);
    $json;

    if (mysqli_connect_errno($connection)) $json = array("sucess" => false, "reason" => mysqli_connect_error);
    else {
        //$login = mysqli_query($connection,"SELECT * FROM users where username = \"" . $_GET["username"] . "\"");
        //$login_row = mysqli_fetch_array($login);

        $result = mysqli_query($connection,"SELECT * FROM settingsTable WHERE setting_ID =\"" . $_GET["GID"] . "\" AND username='\"" . $_GET["username"] . "\"' AND password='\"" . $_GET["password"] . "\"'");
        $result = mysqli_fetch_array($result);

            $result = mysqli_query($connection,"UPDATE settingsTable SET is_deleted='1' WHERE setting_ID =\"" . $_GET["GID"] . "\"");
            if(!$result) $json = array("sucess" => false,"reason" => mysqli_error($connection));
            else $json = array("sucess" => true);

        mysqli_close($connection);
    }//else

    $json_string = json_encode($json);
    echo $json_string;

?>
