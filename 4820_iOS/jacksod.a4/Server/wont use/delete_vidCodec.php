<?php
    // LOGINS NOT SETUP
    // DELETES ID 2
    // WILL NOT BE ALLOWED IN APP

    //define connection values
    include 'config.php';

    $connection = mysqli_connect($DBServer,$DBUser,$DBPass,$DBName);
    $json;

    if (mysqli_connect_errno($connection)) $json = array("sucess" => false, "reason" => mysqli_connect_error);
    else {
        //$login = mysqli_query($connection,"SELECT * FROM users where username = \"" . $_GET["username"] . "\"");
        //$login_row = mysqli_fetch_array($login);

        $result = mysqli_query($connection,"SELECT * FROM videoCodecs where vidCodec_ID = 2");   // \"" . $_GET["GID"] . "\"");
        $result = mysqli_fetch_array($result);

            $result = mysqli_query($connection,"UPDATE videoCodecs SET is_deleted='1' WHERE vidCodec_ID = 2");    //\"" . $_GET["GID"] . "\"");
            if(!$result) $json = array("sucess" => false,"reason" => mysqli_error($connection));
            else $json = array("sucess" => true);

        mysqli_close($connection);
    }//else

    $json_string = json_encode($json);
    echo $json_string;

?>
