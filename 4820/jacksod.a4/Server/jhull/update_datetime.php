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
            $result = mysqli_query($connection,"SELECT * FROM datetime where _id = \"" . $_GET["GID"] . "\"");
            if($result["user"] != $login_row["_id"]){
                $json = array("sucess" => false, "reason" => "You do not have permission to update that datetime.");
            } else {
                $server_timestamp = date($result["timestamp"]);
                $client_timestamp = strtotime($_GET["timestamp"]);
                if($client_timestamp > $server_timestamp){
                    $result = mysqli_query($connection,"UPDATE routes SET hour=\"" . $_GET["hour"]
                    . "\", minute=\"" . $_GET["minute"]
                    . "\", monday=\"" . $_GET["monday"]
                    . "\", tuesday=\"" . $_GET["tuesday"]
                    . "\", wednesday=\"" . $_GET["wednesday"] 
                    . "\", thursday=\"" . $_GET["thursday"] 
                    . "\", friday=\"" . $_GET["friday"] 
                    . "\", is_deleted=\"" . $_GET["is_deleted"]
                    . "\" WHERE _id = \"" . $_GET["GID"] . "\"");
                    if(!$result) $json = array("sucess" => false,"reason" => mysqli_error($connection));
                    else $json = array("sucess" => true);
                }
                $json = array("sucess" => true);
            }
            mysqli_close($connection);
        }
    }   
    $json_string = json_encode($json);  
    echo $json_string;
?>