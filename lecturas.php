<?php
declare(strict_types=1);

require_once __DIR__ . '/config/bootstrap.php';

// Punto de entrada del CRUD de lecturas: recibe los formularios del dashboard
$controller = new ReadingController();

switch ($_POST['action'] ?? '') {
    case 'create':
        $controller->store();
        break;
    case 'update':
        $controller->update();
        break;
    case 'delete':
        $controller->destroy();
        break;
    case 'delete_all':
        $controller->destroyAll();
        break;
    default:
        header('Location: ' . url('dashboard.php'));
        exit;
}
