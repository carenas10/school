<?php

//define connection values
include 'config.php';

$connection = mysqli_connect($DBServer,$DBUser,$DBPass,$DBName);
$json;

    if (mysqli_connect_errno($connection)) $json = array("sucess" => false,"reason" => mysqli_connect_error);
    else {
        //$login = mysqli_query($connection,"SELECT * FROM users where username = \"" . $_GET["username"] . "\"");
        //$login_row = mysqli_fetch_array($login);
        //if($login_row["password"] != $_GET["password"])
        //    $json = array("sucess" => false, "reason" => "Bad username or password");
            $result = mysqli_query($connection,"INSERT INTO settingsTable(name,resolution,bitrate,framerate,vidCodec,audioCodec,username,password,is_deleted) values (\"" . $_GET["name"] . "\",\"" . $_GET["resolution"] . "\",\"" . $_GET["bitrate"] . "\",\"" . $_GET["framerate"] . "\",\"" . $_GET["vidCodec"] . "\",\"" . $_GET["audioCodec"] . "\",\"" . $_GET["username"] . "\",\"" . $_GET["password"] . "\",\"" . $_GET["is_deleted"] . "\")");
            if(!$result) $json = array("sucess" => false,"reason" => mysqli_error($connection));
            else $json = array("sucess" => true, "GID" => $connection->insert_id);
            mysqli_close($connection);
    }
    $json_string = json_encode($json);
    echo $json_string;
?>
