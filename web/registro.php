<?php
require_once 'conexion.php';
$mensaje = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $nombre = trim($_POST['nombre']);
    $apellidos = trim($_POST['apellidos']);
    $pasaporte = trim($_POST['pasaporte']);
    $numero_vuelo = trim($_POST['numero_vuelo']);
    $origen = trim($_POST['origen']);
    $destino = trim($_POST['destino']);
    $fecha_vuelo = $_POST['fecha_vuelo'];
    $asiento = trim($_POST['asiento']);
    $maletas = intval($_POST['maletas_facturadas']);

    if (!empty($nombre) && !empty($pasaporte) && !empty($numero_vuelo)) {
        try {
            // ANTISQL-INJECTION: Sentencia preparada con marcadores genéricos (?)
            $sql = "INSERT INTO pasajeros (nombre, apellidos, pasaporte, numero_vuelo, origen, destino, fecha_vuelo, asiento, maletas_facturadas) 
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            $stmt = $pdo->prepare($sql);
            $stmt->execute([$nombre, $apellidos, $pasaporte, $numero_vuelo, $origen, $destino, $fecha_vuelo, $asiento, $maletas]);
            $mensaje = "<div style='color: green; margin-bottom: 15px;'><b>¡Registro completado!</b> Pasajero registrado con éxito para el vuelo $numero_vuelo.</div>";
        } catch (PDOException $e) {
            $mensaje = "<div style='color: red; margin-bottom: 15px;'>Error al registrar: El pasaporte ya existe o los datos son inválidos.</div>";
        }
    } else {
        $mensaje = "<div style='color: red; margin-bottom: 15px;'>Por favor, rellena todos los campos obligatorios.</div>";
    }
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>FlyHigh Airlines - Registro</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f7f6; }
        .container { max-width: 600px; background: white; padding: 20px; border-radius: 8px; box-shadow: 0px 0px 10px rgba(0,0,0,0.1); }
        h1 { color: #0275d8; }
        label { display: block; margin-top: 10px; font-weight: bold; }
        input, select { width: 100%; padding: 8px; margin-top: 5px; box-sizing: border-box; }
        button { background-color: #0275d8; color: white; border: none; padding: 10px 15px; margin-top: 15px; cursor: pointer; font-size: 16px; width: 100%; }
        button:hover { background-color: #014c8c; }
        nav { margin-bottom: 20px; }
        nav a { margin-right: 15px; text-decoration: none; color: #0275d8; font-weight: bold; }
    </style>
</head>
<body>

    <nav>
        <a href="index.php">Inicio</a> |
        <a href="registro.php">✈️ Registrar Pasajero</a> |
        <a href="buscador.php">🔍 Buscador de Vuelos</a>
    </nav>

    <div class="container">
        <h1>FlyHigh Airlines</h1>
        <h3>Registro de Facturación y Embarque</h3>
        <?php echo $mensaje; ?>

        <form action="registro.php" method="POST">
            <label>Nombre *</label>
            <input type="text" name="nombre" required>

            <label>Apellidos *</label>
            <input type="text" name="apellidos" required>

            <label>Nº de Pasaporte / DNI *</label>
            <input type="text" name="pasaporte" required>

            <label>Número de Vuelo *</label>
            <input type="text" name="numero_vuelo" placeholder="Ej: FH402" required>

            <label>Origen</label>
            <input type="text" name="origen" required>

            <label>Destino</label>
            <input type="text" name="destino" required>

            <label>Fecha del Vuelo</label>
            <input type="date" name="fecha_vuelo" required>

            <label>Asiento asignado</label>
            <input type="text" name="asiento" placeholder="Ej: 12B" required>

            <label>Maletas a facturar</label>
            <input type="number" name="maletas_facturadas" min="0" value="0">

            <button type="submit">Confirmar y Registrar</button>
        </form>
    </div>
</body>
</html>
