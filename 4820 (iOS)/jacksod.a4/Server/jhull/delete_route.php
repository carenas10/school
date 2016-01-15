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
                $json = array("sucess" => false, "reason" => "You do not have permission to delete that route.");
            } else {
                $result = mysqli_query($connection,"UPDATE routes SET is_deleted='1'"
                . " WHERE _id = \"" . $_GET["GID"] . "\"");
                if(!$result) $json = array("sucess" => false,"reason" => mysqli_error($connection));
                else $json = array("sucess" => true);
            }
            mysqli_close($connection);
        }
    }   
    $json_string = json_encode($json);  
    echo $json_string;
?>