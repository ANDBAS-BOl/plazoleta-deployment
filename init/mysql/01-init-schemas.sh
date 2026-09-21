#!/bin/sh
# ============================================================
#  MySQL init script - se ejecuta en el primer arranque del contenedor.
#  Crea los schemas y da permisos al usuario de aplicacion.
#
#  Es un .sh y no un .sql a proposito: un .sql no puede leer variables
#  de entorno, asi que el nombre del usuario quedaba escrito a mano y
#  dejaba de coincidir con el que Compose crea a partir de MYSQL_USER.
#  Al cambiar MYSQL_USER en el .env, los GRANT apuntaban a un usuario
#  inexistente y la aplicacion arrancaba sin permisos.
# ============================================================
set -e

APP_USER="${MYSQL_USER:-pragma_user}"

mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" <<EOSQL
CREATE DATABASE IF NOT EXISTS pragma_usuarios  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS pragma_plazoleta CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

GRANT ALL PRIVILEGES ON pragma_usuarios.*  TO '${APP_USER}'@'%';
GRANT ALL PRIVILEGES ON pragma_plazoleta.* TO '${APP_USER}'@'%';

FLUSH PRIVILEGES;
EOSQL

echo "[init] schemas creados y permisos concedidos a '${APP_USER}'"
