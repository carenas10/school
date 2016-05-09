<?php
 
$dbhostname = 'mysql1.cs.clemson.edu';
 
$dbusername = 'ul0f8gzj';
 
$dbpassword = 'thunderducklings3';
 
$conn = mysql_connect($dbhostname, $dbusername, $dbpassword);
 
if(! $conn )
 
{
 
  die('Could not connect: ' . mysql_error());
 
}
 
if (isset ($_GET["name"], $_GET["intensity"]))
{
		$name = $_GET["name"];
		$intensity = $_GET["intensity"];

}
//echo 'MySQL Connected successfully'."<BR>";
 
mysql_select_db("SmartHomeExternal_l4mz") or die(mysql_error());
 
//echo "Connected to Database"."<BR>";
 if('$intensity'>0)
 {
 $isOnorOff = FALSE;
 }
 else
 {
 $isOnorOff = TRUE;
 }
 
 
    $sql_statement = "UPDATE lights 
    SET intensity =$intensity ,isOnorOff = $isOnorOff
    WHERE name='$name'";
 
$rec_insert = mysql_query( $sql_statement);
 

echo "Entered data successfully\n";
 
mysql_close($conn);
