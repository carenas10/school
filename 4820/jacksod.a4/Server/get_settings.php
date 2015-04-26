<?php
    //define connection values
    include 'config.php';

    $connection = mysqli_connect($DBServer,$DBUser,$DBPass,$DBName);
    $json;

    //connection check
    if (mysqli_connect_errno($connection)) $json = array("sucess" => false, "reason" => mysqli_connect_error);
    else {
        $json = array("sucess" => true);
        $results_array = array("results" => array());

        //query from specific user
        $result = mysqli_query($connection,"SELECT * FROM settingsTable WHERE username=\"" . $_GET["username"] . "\" AND password=\"" . $_GET["password"] . "\"");
        while($row = mysqli_fetch_array($result)) {
            $row_array = array("name" => $row['name'],
                               "resolution" => $row['resolution'],
                               "bitrate" => $row['bitrate'],
                               "framerate" => $row['framerate'],
                               "audioCodec" => $row['audioCodec'],
                               "vidCodec" => $row['vidCodec']);
            array_push($results_array['results'], $row_array);
        }//while

        mysqli_close($connection);
        $json = $json + $results_array;

    }
    $json_string = json_encode($json);
    echo $json_string;
?>
