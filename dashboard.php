<?php
declare(strict_types=1);

require_once __DIR__ . '/config/bootstrap.php';

$controller = new DashboardController();

// POST = botón "Cargar datos de demostración"; GET = mostrar el panel
if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
    $controller->loadDemo();
} else {
    $controller->index();
}
