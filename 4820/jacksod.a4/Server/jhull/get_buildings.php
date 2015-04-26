<?php
    $config = parse_ini_file("config.ini");
    $connection = mysqli_connect($config["hostname"],$config["username"],$config["password"],$config["database"]);
    $json;
    if (mysqli_connect_errno($connection))
    {
        $json = array("sucess" => false, "reason" => mysqli_connect_error);
    }
    else {
        $json = array("sucess" => true);
                    $results_array = array("results" => array());
            $result = mysqli_query($connection,"SELECT * FROM buildings");
            while($row = mysqli_fetch_array($result)) {
                $row_array = array("name" => $row['name'],
                                   "latitude" => $row['latitude'], 
                                   "longitude" => $row['longitude']);
                array_push($results_array['results'], $row_array);
            }
            mysqli_close($connection);
    } 
    $json = $json + $results_array;
    $json_string = json_encode($json);
    echo $json_string;
?>