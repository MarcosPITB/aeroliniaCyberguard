<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Correcaminos Airlines 🦜⚡ - Inicio</title>
    <style>
        /* Estilos Generales */
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f4f7f9; color: #333; }
        /* Barra de Navegación */
        header { background-color: #0f4c81; color: white; padding: 15px 40px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        header .logo { font-size: 24px; font-weight: bold; letter-spacing: 1px; }
        nav a { color: white; text-decoration: none; margin-left: 20px; font-weight: 600; font-size: 15px; transition: color 0.3s; }
        nav a:hover { color: #ffbc00; }

        /* Hero Banner (Sección de bienvenida) */
        .hero { background: linear-gradient(rgba(15, 76, 129, 0.7), rgba(15, 76, 129, 0.7)), url('https://images.unsplash.com/photo-1436491865332-7a61a109cc05?q=80&w=1200') no-repeat center center/cover; height: 350px; color: white; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center; padding: 0 20px; }
        .hero h1 { font-size: 42px; margin-bottom: 10px; text-shadow: 2px 2px 4px rgba(0,0,0,0.5); }
        .hero p { font-size: 18px; max-width: 600px; text-shadow: 1px 1px 3px rgba(0,0,0,0.5); }
        .hero .btn-cta { background-color: #ffbc00; color: #0f4c81; padding: 12px 25px; font-weight: bold; border-radius: 25px; text-decoration: none; margin-top: 15px; box-shadow: 0 4px 10px rgba(0,0,0,0.2); transition: transform 0.2s; }
        .hero .btn-cta:hover { transform: scale(1.05); background-color: #e0a500; }

        /* Contenedor de Secciones */
        .container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }
        h2 { color: #0f4c81; text-align: center; margin-bottom: 30px; position: relative; }
        h2::after { content: ''; display: block; width: 60px; height: 3px; background-color: #ffbc00; margin: 10px auto 0; }

        /* Sección de Ofertas (Tarjetas) */
        .grid-ofertas { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; margin-bottom: 60px; }
        .card { background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); transition: transform 0.3s; }
        .card:hover { transform: translateY(-5px); }
        .card-img { height: 180px; background-size: cover; background-position: center; }
        .card-body { padding: 20px; }
        .card-body h3 { margin: 0 0 10px 0; color: #333; }
        .card-body .precio { font-size: 24px; color: #28a745; font-weight: bold; margin: 15px 0 0 0; }
        .card-body .precio span { font-size: 14px; color: #777; font-weight: normal; }

        /* Sección de Aviones (Flota) */
        .flota { background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); display: flex; align-items: center; gap: 40px; flex-wrap: wrap; }
        .flota-texto { flex: 1; min-width: 300px; }
        .flota-texto ul { list-style: none; padding: 0; }
        .flota-texto li { padding: 8px 0; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; }
        .flota-texto li strong { color: #0f4c81; }

        /* Pie de página */
        footer { background-color: #222; color: #aaa; text-align: center; padding: 20px; font-size: 14px; margin-top: 60px; }
    </style>
</head>
<body>

    <header>
        <div class="logo">🦜⚡ Correcaminos Airlines</div>
        <nav>
            <a href="index.php">Inicio</a>
            <a href="registro.php">Facturación / Registro</a>
            <a href="buscador.php">Buscar Pasajero</a>
        </nav>
    </header>

    <section class="hero">
        <h1>¿Listo para volar a la velocidad del rayo?</h1>
        <p>Viaja con la flota más rápida y segura del espacio aéreo en Correcaminos Airlines. ¡Evita los trucos del coyote y asegura tu asiento!</p>
        <a href="registro.php" class="btn-cta">Hacer Check-in Online ✈️</a>
    </section>

    <div class="container"> 
        <h2>Ofertas Flash de la Semana</h2>
        <div class="grid-ofertas">
            <div class="card">
                <div class="card-img" style="background-image: url('https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=400');"></div>
                <div class="card-body">
                    <h3>Ibiza Sol y Playa</h3>
                    <p>Vuelo directo de ida y vuelta con tasas incluidas. Equipaje de mano permitido.</p>
                    <p class="precio">29€ <span>/ ida y vuelta</span></p>
                </div>
            </div>
            <div class="card">
                <div class="card-img" style="background-image: url('https://images.unsplash.com/photo-1503899036084-c55cdd92da26?q=80&w=400');"></div>
                <div class="card-body">
                    <h3>Tokio Tecnológico</h3>
                    <p>Descubre el país del sol naciente a bordo de nuestros aviones intercontinentales de última generación.</p>
                    <p class="precio">450€ <span>/ ida y vuelta</span></p>
                </div>
            </div>
            <div class="card">
                <div class="card-img" style="background-image: url('https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?q=80&w=400');"></div>
                <div class="card-body">
                    <h3>Nueva York de Ensueño</h3>
                    <p>Cruza el Atlántico cómodamente y disfruta de la Gran Manzana este otoño.</p>
                    <p class="precio">299€ <span>/ ida y vuelta</span></p>
                </div>
            </div>
        </div>

        <h2>Nuestra Flota Ultrarrápida</h2>
        <div class="flota">
            <div class="flota-texto">
                <p>En Correcaminos Airlines invertimos en la tecnología aeronáutica más moderna para garantizar la máxima comodidad y puntualidad en tus trayectos.</p>
                <ul>
                    <li><span><strong>Boeing 787 Dreamliner</strong> (Largo Alcance)</span> <span>12 unidades</span></li>
                    <li><span><strong>Airbus A321neo</strong> (Rutas Europeas)</span> <span>24 unidades</span></li>
                    <li><span><strong>Airbus A350-1000</strong> (Alta Capacidad)</span> <span>8 unidades</span></li>
                </ul>
            </div>
            <div style="flex: 1; min-width: 300px; text-align: center;">
                <img src="https://images.unsplash.com/photo-1540962351504-03099e0a754b?q=80&w=400" alt="Avión Correcaminos" style="width: 100%; max-width: 350px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1);">
            </div>
        </div>

    </div>

    <footer>
        &copy; 2026 Correcaminos Airlines S.A. - Infraestructura corporativa de red y base de datos protegida por pfSense.
    </footer>

</body>
</html>
