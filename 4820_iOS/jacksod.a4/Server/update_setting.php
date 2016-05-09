<?php
include 'config.php';

$connection = mysqli_connect($DBServer,$DBUser,$DBPass,$DBName);
$json;

    if (mysqli_connect_errno($connection)) $json = array("sucess" => false, "reason" => mysqli_connect_error);
    else {
        //$login = mysqli_query($connection,"SELECT * FROM users where username = \"" . $_GET["username"] . "\"");
        //$login_row = mysqli_fetch_array($login);
        //if($login_row["password"] != $_GET["password"]) $json = array("sucess" => false, "reason" => "Bad username or password");
        //else {
            $result = mysqli_query($connection,"SELECT * FROM settingsTable where setting_ID = 6");   //\"" . $_GET["GID"] . "\"");
            $result = mysqli_fetch_array($result);
            //if($result["user"] != $login_row["_id"]){
            //    $json = array("sucess" => false, "reason" => "You do not have permission to update that route.");
            //} else {
                //$server_timestamp = date($result["timestamp"]);
                //$client_timestamp = strtotime($_GET["timestamp"]);
                //if($client_timestamp > $server_timestamp){
                    $result = mysqli_query($connection,"UPDATE settingsTable SET name='reset_putTest',resolution='150x150',bitrate=5000,framerate=30,vidCodec=1,audioCodec=1 where setting_ID = 6");  //to_buiding=\"" . $_GET["to"] . "\", from_building=\"" . $_GET["from"] . "\", datetime=\"" . $_GET["datetime"] . "\", is_deleted=\"" . $_GET["is_deleted"] . "\" WHERE _id = \"" . $_GET["GID"] . "\"");
                    if(!$result) $json = array("sucess" => false,"reason" => mysqli_error($connection));
                    else $json = array("sucess" => true);
              //}//if
          //}//else
            mysqli_close($connection);
        //}else
    }
    $json_string = json_encode($json);
    echo $json_string;
?>
