# CultivaTech · Smart Agriculture

Plataforma web para monitorear temperatura, humedad ambiental, humedad del suelo (capacitivo) y CO₂ de un cultivo.
PHP nativo (8.1 o superior), MySQL con PDO, patrón MVC, HTML/CSS/JS sin frameworks.

## Instalación en XAMPP

1. Copia la carpeta `cultivatech` dentro de `htdocs` (queda `C:\xampp\htdocs\cultivatech`).
2. Inicia **Apache** y **MySQL** desde el panel de XAMPP.
3. Abre `http://localhost/phpmyadmin`, entra a **Importar** y selecciona `database.sql`.
   Crea la base `cultivatech`, la tabla `usuarios` y la tabla `lecturas_sensores`.
4. Si tu MySQL tiene otra contraseña o puerto, edita `config/config.php` (`DB_USER`, `DB_PASS`, `DB_PORT`).
5. Abre `http://localhost/cultivatech/`.

La ruta base se detecta sola, así que también funciona si cambias el nombre de la carpeta.

## Estructura de directorios

```
cultivatech/
├── index.php            Landing page
├── login.php            Inicio de sesión
├── register.php         Registro de usuarios
├── dashboard.php        Panel privado (requiere sesión)
├── lecturas.php         CRUD de lecturas: recibe los formularios del dashboard (POST + CSRF)
├── logout.php           Cierre de sesión (POST + CSRF)
├── database.sql         Script de la base de datos
├── .htaccess            Sin listado de directorios, bloquea .sql/.md
│
├── api/
│   ├── lecturas.php     POST: el dispositivo envía una lectura (clave API)
│   └── dashboard.php    GET: resumen JSON para refrescar el panel (sesión)
│
├── config/
│   ├── config.php       BD, zona horaria, umbrales de los 4 sensores
│   └── bootstrap.php    Carga el núcleo, modelos y controladores
│
├── core/                Infraestructura compartida
│   ├── Database.php     Conexión PDO (singleton)
│   ├── Session.php      Sesión, login, CSRF, límite de intentos
│   ├── Controller.php   Render, redirecciones, JSON, guardas de acceso
│   └── helpers.php      e(), url(), asset(), icon()
│
├── models/              M · acceso a datos
│   ├── User.php
│   └── SensorReading.php
│
├── controllers/         C · lógica de cada pantalla
│   ├── HomeController.php
│   ├── AuthController.php
│   ├── DashboardController.php
│   ├── ReadingController.php   CRUD de lecturas
│   └── ApiController.php
│
├── views/               V · plantillas HTML
│   ├── home.php
│   ├── dashboard.php
│   ├── auth/login.php
│   ├── auth/register.php
│   └── partials/        head, footer, nav_public
│
└── assets/
    ├── css/style.css
    ├── js/dashboard.js   Tendencias y refresco automático
    ├── js/readings.js    Diálogos del CRUD
    └── img/logo.png
```

Los archivos de la raíz (`index.php`, `login.php`, etc.) son puntos de entrada delgados:
cargan `config/bootstrap.php` y llaman al controlador. Las carpetas `config`, `core`, `models`,
`controllers` y `views` tienen un `.htaccess` que impide abrirlas desde el navegador.

## Probar el panel

1. Crea una cuenta en `register.php`.
2. En el panel pulsa **Cargar datos de demostración** (genera 48 lecturas simuladas).
3. Para usar un dispositivo real, copia el endpoint y tu clave API desde el panel:

```bash
curl -X POST "http://localhost/cultivatech/api/lecturas.php" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: TU_CLAVE_API" \
  -d '{"temperatura":24.8,"humedad_ambiente":68.2,"humedad_suelo":55.4,"co2":612}'
```

El panel se actualiza solo cada 15 segundos. Los umbrales óptimo/atención/crítico de cada
sensor se ajustan en `config/config.php` (constante `SENSORS`).

## CRUD de lecturas en el dashboard

En el panel, la sección **Lecturas registradas** permite gestionar los datos de tu cultivo:

| Acción | Cómo |
|---|---|
| Agregar | Botón **Agregar lectura**: fecha, temperatura, humedad ambiental, humedad del suelo y CO₂ |
| Editar | Botón **Editar** en cada fila (el formulario se abre con los valores actuales) |
| Eliminar una | Botón **Eliminar** en cada fila, con confirmación |
| Eliminar todas | Botón **Eliminar todas**, con confirmación |

La tabla muestra 10 lecturas por página, con un punto de color por valor (verde óptimo, ámbar atención, rojo crítico).
El servidor valida cada dato (número dentro del rango físico del sensor, fecha válida y no futura) y solo permite
tocar lecturas de la cuenta que inició sesión. Las tarjetas y gráficas se calculan con las últimas 48 lecturas, así que
reflejan los cambios al recargar la página o en el siguiente refresco automático.

## Seguridad incluida

- Consultas con PDO y sentencias preparadas reales (sin emulación).
- Contraseñas con `password_hash` / `password_verify`, con re-hash automático si cambia el algoritmo.
- Sesiones con cookie `HttpOnly` y `SameSite=Lax`, y regeneración de id al iniciar sesión.
- Token CSRF en todos los formularios, incluidos el cierre de sesión y el CRUD.
- Cada consulta del CRUD filtra por `usuario_id`: nadie puede editar ni borrar lecturas de otra cuenta.
- Bloqueo de 60 s tras 5 intentos de login fallidos.
- Salida HTML escapada con `e()`.
- La API valida la clave y los rangos físicos de cada medida.

Para producción en un servidor real, sirve el sitio por HTTPS (la cookie de sesión pasa a `Secure` automáticamente).
