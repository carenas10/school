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

 
  $result = mysql_query("SELECT * FROM motionDetector
    ORDER BY id DESC LIMIT 1");
if (!$result) {
    echo 'Could not run query: ' . mysql_error();
    exit;
}
$row = mysql_fetch_row($result);
echo "Is currently detecting motion:  ";
echo $row[1]; 
// 0 means not detecting motion
// 1 means detecting motion
// nothing means there is no data
//echo "Entered data successfully\n";
 
mysql_close($conn);
