<?php

$dbhostname = 'mysql1.cs.clemson.edu';

$dbusername = 'ul0f8gzj';

$dbpassword = 'thunderducklings3';

$conn = mysql_connect($dbhostname, $dbusername, $dbpassword);

if(! $conn )

{

  die('Could not connect: ' . mysql_error());

}

if (isset ($_GET["username"], $_GET["password"]))
{
		$username = $_GET["username"];
		$password = $_GET["password"];

}
if(empty($username) || empty($password))
{
echo ('Username or password field was empty');
}

//echo 'MySQL Connected successfully'."<BR>";

mysql_select_db("SmartHomeExternal_l4mz") or die(mysql_error());

 $result = mysql_query("SELECT * FROM users WHERE username = '$username' && password = '$password'");
if (!$result) {
    echo 'Could not run query: ' . mysql_error();
    exit;
}
$row = mysql_fetch_row($result);
//echo "ARE YOU AN ADMIN?  ";
echo $row[3]; // the is admin value
// if this is a 1 then you are an admin.
// if this is a 0 then your not an admin
// if this is NULL then the data you entered is not in the database

mysql_close($conn);
