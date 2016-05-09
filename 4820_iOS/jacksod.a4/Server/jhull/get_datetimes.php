<?php
    $config = parse_ini_file("config.ini");
    $connection = mysqli_connect($config["hostname"],$config["username"],$config["password"],$config["database"]);
    if (mysqli_connect_errno($connection)) $json = array("sucess" => false, "reason" => mysqli_connect_error);
    else {
        $login = mysqli_query($connection,"SELECT * FROM users where username = \"" . $_GET["username"] . "\"");
        $login_row = mysqli_fetch_array($login);
        if($login_row["password"] != $_GET["password"]) $json = array("sucess" => false, "reason" => "Bad username or password");
        else {
            $json = array("sucess" => true);
            $results_array = array("results" => array());
            $result = mysqli_query($connection,"SELECT * FROM datetimes where user = \"" . $login_row["_id"] . "\"");
            while($row = mysqli_fetch_array($result)) {
                $row_array = array("hour" => $row['hour'],
                    "minute" => $row['minute'],
                    "monday" => $row['monday'],
                    "tuesday" => $row['tuesday'],
                    "wednesday" => $row['wednesday'],
                    "thursday" => $row['thursday'],
                    "friday" => $row['friday'],
                    "is_deleted" => $row['is_deleted'],
                    "GID" => $row['_id']);
                array_push($results_array['results'], $row_array);
            }
            mysqli_close($connection);
            $json = $json + $results_array;
        }
    }   
    $json_string = json_encode($json);  
    echo $json_string;
?>