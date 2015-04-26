<?php
    $config = parse_ini_file("config.ini");
    $connection = mysqli_connect($config["hostname"],$config["username"],$config["password"],$config["database"]);
    $json;
    if (mysqli_connect_errno($connection)) $json = array("sucess" => false,
        "reason" => mysqli_connect_error);
    else {
        $login = mysqli_query($connection,
            "SELECT * FROM users where username = \"" . $_GET["username"] . "\"");
        $login_row = mysqli_fetch_array($login);
        if($login_row["password"] != $_GET["password"])
            $json = array("sucess" => false, "reason" => "Bad username or password");
        else {
            $result = mysqli_query($connection,
                "INSERT INTO routes (to_buiding, from_building, datetime, user, is_deleted) 
                values (" . $_GET["to"] . ", " . $_GET["from"] . ", "
                . $_GET["datetime"] . ", " . $login_row["_id"] . ", " . $_GET["is_deleted"]. ")");
            if(!$result) $json = array("sucess" => false,
                "reason" => mysqli_error($connection));
            else $json = array("sucess" => true, "GID" => $connection->insert_id);
            mysqli_close($connection);
        }
    }   
    $json_string = json_encode($json);  
    echo $json_string;
?>
