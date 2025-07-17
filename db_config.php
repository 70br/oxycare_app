<?php
$host = "silvaelias.ddns.net";
$user = "isaias";
$pass = "Isaias#405020"; // ou sua senha do MySQL se tiver
$db = "oxycare";

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die("Falha na conexão: " . $conn->connect_error);
}
?>
