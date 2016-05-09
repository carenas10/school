<?php
 
$dbhostname = 'mysql1.cs.clemson.edu';
 
$dbusername = 'ul0f8gzj';
 
$dbpassword = 'thunderducklings3';
 
$conn = mysql_connect($dbhostname, $dbusername, $dbpassword);
 
if(! $conn )
 
{
 
  die('Could not connect: ' . mysql_error());
 
}
 
if (isset ($_GET["currentTemp"]))
		$currentTemp = $_GET["currentTemp"];
//echo 'MySQL Connected successfully'."<BR>";
 
mysql_select_db("SmartHomeExternal_l4mz") or die(mysql_error());
 
//echo "Connected to Database"."<BR>";
 
  
  $result = mysql_query("SELECT * FROM idealValues");
if (!$result) {
    echo 'Could not run query: ' . mysql_error();
    exit;
}
$row = mysql_fetch_row($result);
//echo "Set temperature is:  ";
$setTemp = $row[1];
//echo $setTemp; 

if($setTemp == $currentTemp)
{
$isOnorOff = FALSE;
}
else
{
$isOnorOff = TRUE;
} 
 
 
 
 
    $sql_statement = "INSERT INTO temperature (currentTemp, isOnorOff, time) 
    VALUES ($currentTemp, $isOnorOff, now())";
 
$rec_insert = mysql_query( $sql_statement);
 
if(! $rec_insert )
 
{
 
  die('Could not enter data: ' . mysql_error());
 
}
 
//echo "Entered data successfully\n";
 echo $isOnorOff;
 // print out whether the thermometer should be turned on or not.
mysql_close($conn);
