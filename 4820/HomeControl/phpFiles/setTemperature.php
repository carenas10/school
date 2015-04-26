<?php
 
$dbhostname = 'mysql1.cs.clemson.edu';
 
$dbusername = 'ul0f8gzj';
 
$dbpassword = 'thunderducklings3';
 
$conn = mysql_connect($dbhostname, $dbusername, $dbpassword);
 
if(! $conn )
 
{
 
  die('Could not connect: ' . mysql_error());
 
}
 
if (isset ($_GET["setTemp"]))
		$setTemp = $_GET["setTemp"];
echo 'MySQL Connected successfully'."<BR>";
 
mysql_select_db("SmartHomeExternal_l4mz") or die(mysql_error());
 
echo "Connected to Database"."<BR>";
 
    $sql_statement = "UPDATE idealValues 
    SET setTemp = $setTemp";
 
$rec_insert = mysql_query( $sql_statement);
 
if(! $rec_insert )
 
{
 
  die('Could not enter data: ' . mysql_error());
 
}
 
echo "Entered data successfully\n";
 
mysql_close($conn);
