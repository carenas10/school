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

        //query all (no specific users)
        $result = mysqli_query($connection,"SELECT * FROM videoCodecs");// where user = \"" . $login_row["_id"] . "\"");
        while($row = mysqli_fetch_array($result)) {
            $row_array = array("vidCodecName" => $row['vidCodecName']);
            array_push($results_array['results'], $row_array);
        }//while

        mysqli_close($connection);
        $json = $json + $results_array;

    }
    $json_string = json_encode($json);
    echo $json_string;
?>
