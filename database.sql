-- ============================================================
--  CultivaTech · Script de base de datos (MySQL / MariaDB)
--  Importar desde phpMyAdmin (XAMPP) o con:
--    mysql -u root < database.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS cultivatech
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE cultivatech;

-- ------------------------------------------------------------
--  Usuarios
--  api_key: clave personal que usa el dispositivo (ESP32, etc.)
--  para enviar lecturas a api/lecturas.php
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(80)  NOT NULL,
    email         VARCHAR(150) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    api_key       CHAR(64)     NOT NULL,
    creado_en     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_usuarios_email (email),
    UNIQUE KEY uq_usuarios_api_key (api_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
--  Lecturas de sensores
--  temperatura      -> °C
--  humedad_ambiente -> % HR
--  humedad_suelo    -> % (sensor capacitivo, ya calibrado a porcentaje)
--  co2              -> ppm
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lecturas_sensores (
    id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    usuario_id       INT UNSIGNED    NOT NULL,
    temperatura      DECIMAL(5,2)    NOT NULL,
    humedad_ambiente DECIMAL(5,2)    NOT NULL,
    humedad_suelo    DECIMAL(5,2)    NOT NULL,
    co2              SMALLINT UNSIGNED NOT NULL,
    registrado_en    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_lecturas_usuario_fecha (usuario_id, registrado_en),
    CONSTRAINT fk_lecturas_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
