<?php
 
$dbhostname = 'mysql1.cs.clemson.edu';
 
$dbusername = 'ul0f8gzj';
 
$dbpassword = 'thunderducklings3';
 
$conn = mysql_connect($dbhostname, $dbusername, $dbpassword);
 
if(! $conn )
 
{
 
  die('Could not connect: ' . mysql_error());
 
}
 
if (isset ($_GET["currHumid"]))
		$currHumid = $_GET["currHumid"];
//echo 'MySQL Connected successfully'."<BR>";
 
mysql_select_db("SmartHomeExternal_l4mz") or die(mysql_error());
 
//echo "Connected to Database"."<BR>";
 
  
  $result = mysql_query("SELECT * FROM idealValues");
if (!$result) {
    echo 'Could not run query: ' . mysql_error();
    exit;
}
$row = mysql_fetch_row($result);
//echo "Set humidity is:  ";
$setHumidity = $row[2];
//echo $setHumidity; 

if($currHumid == $setHumidity)
{
$isOnorOff = FALSE;
}
else
{
$isOnorOff = TRUE;
} 
 
 
 
 
    $sql_statement = "INSERT INTO humidity (currHumid, isOnorOff, time) 
    VALUES ($currHumid, $isOnorOff, now())";
 
$rec_insert = mysql_query( $sql_statement);
 
if(! $rec_insert )
 
{
 
  die('Could not enter data: ' . mysql_error());
 
}
 
//echo "<br>The actuator for Humidity should be on? (F=0 or T=1) :  \n";
 echo $isOnorOff;
 // print out whether the humidifier should be turned on or not.
mysql_close($conn);
