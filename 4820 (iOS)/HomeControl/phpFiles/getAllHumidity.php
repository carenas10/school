<?php
 
$dbhostname = 'mysql1.cs.clemson.edu';
 
$dbusername = 'ul0f8gzj';
 
$dbpassword = 'thunderducklings3';
 
$conn = mysql_connect($dbhostname, $dbusername, $dbpassword);
 
if(! $conn )
 
{
 
  die('Could not connect: ' . mysql_error());
 
}
 

//echo 'MySQL Connected successfully'."<BR>";
 
mysql_select_db("SmartHomeExternal_l4mz") or die(mysql_error());
 
//echo "Connected to Database"."<BR>";

 
$sql_statement = "SELECT * FROM humidity";
$result = mysql_query($sql_statement);


    while($row = mysql_fetch_assoc($result)) 
    {
        echo $row['currHumid'] . " " . $row['time']. "<br>";
    }


 
//echo "Entered data successfully\n";
 
mysql_close($conn);
