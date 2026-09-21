# Plazoleta Deployment (Infra)

Este repositorio es la infraestructura maestra (Docker) para levantar las bases de datos necesarias del Sistema Plaza de Comidas:

- MySQL (esquemas `pragma_usuarios` y `pragma_plazoleta`)
- MongoDB (base `pragma_trazabilidad`)

Microservicios:
- `usuarios-microservice`
- `plazoleta-microservice`
- `mensajeria-microservice`
- `trazabilidad-microservice`

## El sistema completo

Este repositorio es **un componente del Sistema Plaza de Comidas**, compuesto por 4 microservicios independientes más su infraestructura. Cada servicio tiene su propia base de datos y valida el JWT de forma autónoma.

> **Para levantar el sistema, empieza por [`plazoleta-deployment`](https://github.com/ANDBAS-BOl/plazoleta-deployment)**, que arranca MySQL y MongoDB.

| Repositorio | Responsabilidad | Datos |
|---|---|---|
| [`usuarios-microservice`](https://github.com/ANDBAS-BOl/usuarios-microservice) | Usuarios, roles y **emisión de JWT** (único emisor del sistema) | MySQL |
| [`plazoleta-microservice`](https://github.com/ANDBAS-BOl/plazoleta-microservice) | Catálogo de restaurantes/platos, flujo de pedidos y PIN de entrega | MySQL |
| [`trazabilidad-microservice`](https://github.com/ANDBAS-BOl/trazabilidad-microservice) | Historial de estados de pedidos y métricas de eficiencia | MongoDB |
| [`mensajeria-microservice`](https://github.com/ANDBAS-BOl/mensajeria-microservice) | Envío del SMS con el PIN, vía Twilio | — |
| **`plazoleta-deployment`** ← estás aquí | Infraestructura Docker: MySQL y MongoDB del sistema | — |

---
## Requisitos

- Docker + Docker Compose v2
- Puertos libres: `3306`, `27017`, `8081`, `8082`, `8083`, `8084`

## 1) Clonar los 4 microservicios

Clona los repositorios en carpetas separadas:

```bash
git clone https://github.com/ANDBAS-BOl/usuarios-microservice
git clone https://github.com/ANDBAS-BOl/plazoleta-microservice
git clone https://github.com/ANDBAS-BOl/mensajeria-microservice
git clone https://github.com/ANDBAS-BOl/trazabilidad-microservice
```

## 2) Configurar variables de BD

```bash
cp .env.example .env
```

## 3) Levantar bases de datos

**Importante — pasa siempre `--env-file .env`.** Compose no busca el `.env` en tu carpeta actual, sino junto al archivo compose (es decir, en `docker/`). Como el paso anterior deja el `.env` en la raíz del repositorio, lanzar el compose sin ese flag **ignora tu `.env` en silencio** y usa los valores por defecto, sin avisar de nada.

> **No uses `--project-directory` para esto.** Sí hace que se lea el `.env`, pero también cambia la base contra la > que se resuelven las rutas relativas del compose: `../init/mysql` pasa a apuntar *fuera* del repositorio y los > contenedores arrancan sin esquemas ni usuarios. `--env-file` arregla el `.env` sin tocar los montajes.

Desde la carpeta raíz de `plazoleta-deployment`:

```bash
docker compose --env-file .env -f docker/compose-db.yml up -d
```

### Re-ejecución de init (Mongo / HU17)

Si ya existían volúmenes previos, los scripts en `plazoleta-deployment/init/*` pueden no volver a ejecutarse (por ejemplo, el usuario de Mongo `pragma_user`). En ese caso, HU17 puede fallar con `500 AuthenticationFailed`.

Para forzar la re-ejecución de init y volver a crear usuarios/colecciones:

```bash
docker compose --env-file .env -f docker/compose-db.yml down -v
docker compose --env-file .env -f docker/compose-db.yml up -d
```

Notas importantes:

- El contenedor de MySQL se llama exactamente `pragma-sql`.
- Los microservicios en Docker se conectan usando los hostnames `pragma-mysql` y `pragma-mongodb`; para compatibilidad, este compose configura aliases dentro de la red `pragma-net`.

## 4) Levantar los microservicios (Docker)

En cada carpeta de microservicio ejecuta:

```bash
docker compose up -d --build
```

Los `docker-compose.yml` de los microservicios declaran una red `pragma-net` como `external: true`. Este repo la crea con el nombre exacto `pragma-net` al levantar la BD, por lo que los microservicios podrán conectarse.

## 5) Verificación rápida

1. Verifica que estén corriendo los contenedores:
   - `pragma-sql` (MySQL)
   - `pragma-mongodb` (MongoDB)
   - `pragma-usuarios`, `pragma-plazoleta`, `pragma-mensajeria`, `pragma-trazabilidad` (microservicios)

2. Abre los servicios en:
   - `http://localhost:8081`
   - `http://localhost:8082`
   - `http://localhost:8083`
   - `http://localhost:8084`

3. **OpenAPI / Swagger (Springdoc):** en cada puerto, la UI suele estar en `/swagger-ui.html` o `/swagger-ui/index.html` y el JSON en `/v3/api-docs` (rutas públicas según `WebSecurityConfig` de cada MS):
   - Usuarios: `http://localhost:8081/swagger-ui.html`
   - Plazoleta: `http://localhost:8082/swagger-ui.html`
   - Trazabilidad: `http://localhost:8083/swagger-ui.html`
   - Mensajería: `http://localhost:8084/swagger-ui.html`

4. **Tests automatizados:** cada microservicio trae su propia suite y se ejecuta desde su carpeta con
   `./gradlew test`. No hace falta levantar nada de este repositorio para correrlos.

   Qué cubre cada suite, los umbrales de cobertura y cómo generar el reporte de JaCoCo están
   documentados en el README de cada repositorio, que es la fuente que se mantiene al día:

   - [`usuarios-microservice`](https://github.com/ANDBAS-BOl/usuarios-microservice)
   - [`plazoleta-microservice`](https://github.com/ANDBAS-BOl/plazoleta-microservice)
   - [`trazabilidad-microservice`](https://github.com/ANDBAS-BOl/trazabilidad-microservice)
   - [`mensajeria-microservice`](https://github.com/ANDBAS-BOl/mensajeria-microservice)

   `trazabilidad` levanta un MongoDB embebido y `mensajeria` usa un mock del proveedor SMS, así que
   sus pruebas corren sin Docker, sin base de datos y sin credenciales de Twilio.

## Estructura de carpetas

- `docker/compose-db.yml`: compose maestro para MySQL + MongoDB
- `init/`: scripts de inicialización (MySQL schemas + Mongo user/collections)