<?php
$con = mysql_connect(localhost,remoteadmin,admin123);
if (!$con) {
    dir('There was a problem when trying to connect to the host. Please contact Tech Support. Error: ' . mysql_error());    
}
$db_selected = mysql_select_db(handover, $con);
if (!$con) {
    dir('There was a problem when trying to connect to the database. Please contact Tech Support. Error: ' . mysql_error());    
}
?>
