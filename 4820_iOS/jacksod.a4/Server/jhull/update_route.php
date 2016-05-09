<?php
    $config = parse_ini_file("config.ini");
    $connection = mysqli_connect($config["hostname"],$config["username"],$config["password"],$config["database"]);
    $json;
    if (mysqli_connect_errno($connection)) $json = array("sucess" => false, "reason" => mysqli_connect_error);
    else {
        $login = mysqli_query($connection,"SELECT * FROM users where username = \"" . $_GET["username"] . "\"");
        $login_row = mysqli_fetch_array($login);
        if($login_row["password"] != $_GET["password"]) $json = array("sucess" => false, "reason" => "Bad username or password");
        else {
            $result = mysqli_query($connection,"SELECT * FROM routes where _id = \"" . $_GET["GID"] . "\"");
            $result = mysqli_fetch_array($result);
            if($result["user"] != $login_row["_id"]){
                $json = array("sucess" => false, "reason" => "You do not have permission to update that route.");
            } else {
                $server_timestamp = date($result["timestamp"]);
                $client_timestamp = strtotime($_GET["timestamp"]);
                if($client_timestamp > $server_timestamp){
                    $result = mysqli_query($connection,"UPDATE routes SET to_buiding=\"" . $_GET["to"]
                    . "\", from_building=\"" . $_GET["from"]
                    . "\", datetime=\"" . $_GET["datetime"]
                    . "\", is_deleted=\"" . $_GET["is_deleted"]
                    . "\" WHERE _id = \"" . $_GET["GID"] . "\"");
                    if(!$result) $json = array("sucess" => false,"reason" => mysqli_error($connection));
                    else $json = array("sucess" => true);
                }
            }
            mysqli_close($connection);
        }
    }   
    $json_string = json_encode($json);  
    echo $json_string;
?>