<?php
require_once 'conexion.php';
$resultados = [];
$busqueda_realizada = false;

if (isset($_GET['buscar']) && !empty(trim($_GET['buscar']))) {
    $buscar = trim($_GET['buscar']);
    $busqueda_realizada = true;

    try {
        // ANTISQL-INJECTION: Usamos placeholders con nombre (:busqueda) para blindar la query
        $sql = "SELECT * FROM pasajeros WHERE nombre ILIKE :busqueda OR apellidos ILIKE :busqueda OR pasaporte = :pasaporte_exacto";
        $stmt = $pdo->prepare($sql);
        // Pasamos los comodines % dentro del array de ejecución de forma segura
        $stmt->execute([
            ':busqueda' => '%' . $buscar . '%',
            ':pasaporte_exacto' => $buscar
        ]);
        $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        die("Error seguro en la búsqueda: " . $e->getMessage());
    }
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Buscador de Pasajeros - FlyHigh</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f7f6; }
        .container { max-width: 900px; background: white; padding: 20px; border-radius: 8px; box-shadow: 0px 0px 10px rgba(0,0,0,0.1); }
        h1 { color: #0275d8; }
        input { width: 75%; padding: 8px; box-sizing: border-box; }
        button { background-color: #28a745; color: white; border: none; padding: 8px 15px; cursor: pointer; font-size: 16px; }
        button:hover { background-color: #218838; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        table, th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background-color: #0275d8; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
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
        <h1>Sistema de Manifiesto de Pasajeros</h1>
        <h3>Buscar por Nombre, Apellidos o Pasaporte</h3>
        <form action="buscador.php" method="GET">
            <input type="text" name="buscar" placeholder="Escribe el nombre o documento a buscar..." value="<?php echo isset($_GET['buscar']) ? htmlspecialchars($_GET['buscar']) : ''; ?>" required>
            <button type="submit">Buscar</button>
        </form>

        <?php if ($busqueda_realizada): ?>
            <?php if (count($resultados) > 0): ?>
                <table>
                    <thead>
                        <tr>
                            <th>Nombre Completo</th>
                            <th>Pasaporte</th>
                            <th>Vuelo</th>
                            <th>Ruta</th>
                            <th>Fecha</th>
                            <th>Asiento</th>
                            <th>Maletas</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($resultados as $pasajero): ?>
                            <tr>
                                <td><?php echo htmlspecialchars($pasajero['nombre'] . ' ' . $pasajero['apellidos']); ?></td>
                                <td><?php echo htmlspecialchars($pasajero['pasaporte']); ?></td>
                                <td><strong><?php echo htmlspecialchars($pasajero['numero_vuelo']); ?></strong></td>
                                <td><?php echo htmlspecialchars($pasajero['origen'] . ' ➔ ' . $pasajero['destino']); ?></td>
                                <td><?php echo htmlspecialchars($pasajero['fecha_vuelo']); ?></td>
                                <td><?php echo htmlspecialchars($pasajero['asiento']); ?></td>
                                <td><?php echo htmlspecialchars($pasajero['maletas_facturadas']); ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php else: ?>
                <p style="margin-top: 20px; color: red;">No se encontraron pasajeros que coincidan.</p>
            <?php endif; ?>
        <?php endif; ?>
    </div>
</body>
</html>
