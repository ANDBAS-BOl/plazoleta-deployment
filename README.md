# Plazoleta Deployment (Infra)

Este repositorio es la infraestructura maestra (Docker) para levantar las bases de datos necesarias del Sistema Plaza de Comidas:

- MySQL (esquemas `pragma_usuarios` y `pragma_plazoleta`)
- MongoDB (base `pragma_trazabilidad`)

Microservicios:
- `usuarios-microservice`
- `plazoleta-microservice`
- `mensajeria-microservice`
- `trazabilidad-microservice`

## Requisitos

- Docker + Docker Compose v2
- Puertos libres: `3306`, `27017`, `8081`, `8082`, `8083`, `8084`

## 1) Clonar los 4 microservicios

Clona los repositorios en carpetas separadas (reemplaza las URLs):

```bash
git clone <URL_USUARIOS_MICROSERVICE> usuarios-microservice
git clone <URL_PLAZOLETA_MICROSERVICE> plazoleta-microservice
git clone <URL_MENSAJERIA_MICROSERVICE> mensajeria-microservice
git clone <URL_TRAZABILIDAD_MICROSERVICE> trazabilidad-microservice
```

> Si ya tienes los microservicios descargados (como en este workspace), puedes omitir este paso.

## 2) Configurar variables de BD

```bash
cp .env.example .env
```

## 3) Levantar bases de datos

Desde la carpeta raíz de `plazoleta-deployment`:

```bash
docker compose -f docker/compose-db.yml up -d
```

Notas importantes:

- El contenedor de MySQL se llama exactamente `plazoleta-deployment` (cumple la convención pedida).
- Los microservicios en Docker se conectan usando los hostnames `pragma-mysql` y `pragma-mongodb`; para compatibilidad, este compose configura aliases dentro de la red `pragma-net`.

## 4) Levantar los microservicios (Docker)

En cada carpeta de microservicio ejecuta:

```bash
docker compose up -d --build
```

Los `docker-compose.yml` de los microservicios declaran una red `pragma-net` como `external: true`. Este repo la crea con el nombre exacto `pragma-net` al levantar la BD, por lo que los microservicios podrán conectarse.

## 5) Verificación rápida

1. Verifica que estén corriendo los contenedores:
   - `plazoleta-deployment` (MySQL)
   - `pragma-mongodb` (MongoDB)
   - `pragma-usuarios`, `pragma-plazoleta`, `pragma-mensajeria`, `pragma-trazabilidad` (microservicios)

2. Abre los servicios en:
   - `http://localhost:8081`
   - `http://localhost:8082`
   - `http://localhost:8083`
   - `http://localhost:8084`

## Estructura de carpetas

- `docker/compose-db.yml`: compose maestro para MySQL + MongoDB
- `init/`: scripts de inicialización (MySQL schemas + Mongo user/collections)

