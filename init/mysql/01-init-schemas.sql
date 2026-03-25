-- ============================================================
--  MySQL init script – ejecutado al primer arranque del contenedor
--  Crea los schemas y el usuario de aplicación con los permisos
--  mínimos necesarios para cada microservicio.
-- ============================================================

-- Schemas
CREATE DATABASE IF NOT EXISTS pragma_usuarios  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS pragma_plazoleta CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Permisos al usuario de aplicación (por defecto: pragma_user / pragma_pass)
GRANT ALL PRIVILEGES ON pragma_usuarios.*  TO 'pragma_user'@'%';
GRANT ALL PRIVILEGES ON pragma_plazoleta.* TO 'pragma_user'@'%';

FLUSH PRIVILEGES;

