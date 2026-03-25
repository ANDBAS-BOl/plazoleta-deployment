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

**Importante:** ejecuta siempre `docker compose -f docker/compose-db.yml` **desde la carpeta raíz de este repositorio** (`plazoleta-deployment`), no desde `docker/` ni desde otra ruta. El archivo `compose-db.yml` monta los scripts de init con rutas relativas (`../init/mysql`, `../init/mongo`); si el directorio de trabajo de Compose no es `plazoleta-deployment`, esas rutas apuntan a carpetas equivocadas y MySQL/Mongo pueden arrancar sin esquemas ni usuarios. Si necesitas lanzar el compose desde otro sitio, usa `docker compose --project-directory /ruta/a/plazoleta-deployment -f /ruta/a/plazoleta-deployment/docker/compose-db.yml up -d` (o equivalente con `working_dir` en tu entorno).

Desde la carpeta raíz de `plazoleta-deployment`:

```bash
docker compose -f docker/compose-db.yml up -d
```

### Re-ejecución de init (Mongo / HU17)

Si ya existían volúmenes previos, los scripts en `plazoleta-deployment/init/*` pueden no volver a ejecutarse (por ejemplo, el usuario de Mongo `pragma_user`). En ese caso, HU17 puede fallar con `500 AuthenticationFailed`.

Para forzar la re-ejecución de init y volver a crear usuarios/colecciones:

```bash
docker compose -f docker/compose-db.yml down -v
docker compose -f docker/compose-db.yml up -d
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

4. **Tests automatizados (`./gradlew test`):** cobertura orientativa por microservicio (Fase 6 del plan):
   - **usuarios:** `UsuarioUseCaseTest`, `UsuariosApiIT` (API + H2), smoke de contexto.
   - **plazoleta:** `PlazoletaServiceTest` (reglas de pedido, PIN, concurrencia, rollback SMS, etc.), `PlazoletaServiceContractTest` (WireMock: Usuarios, Mensajería, Trazabilidad).
   - **mensajería:** `MensajeriaRestControllerTest` (JWT y endpoint SMS).
   - **trazabilidad:** `OrderTraceApiIT`, smoke de contexto.

## Estructura de carpetas

- `docker/compose-db.yml`: compose maestro para MySQL + MongoDB
- `init/`: scripts de inicialización (MySQL schemas + Mongo user/collections)