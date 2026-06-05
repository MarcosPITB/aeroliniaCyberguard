<?php
// conexion.php
$host = "10.0.8.5"; // IP de tu servidor de Base de Datos
$port = "5432";
$dbname = "aerolinea";
$user = "pau";
$password = "buenosdias"; // La contraseña que pusiste en el script SQL

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname;";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
} catch (PDOException $e) {
    die("Error crítico de conexión: " . $e->getMessage());
}
?>
