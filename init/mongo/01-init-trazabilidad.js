// ============================================================
//  MongoDB init script - se ejecuta en el primer arranque.
//  Crea la base de trazabilidad y su usuario de aplicacion.
//
//  Las credenciales se leen del entorno (MONGO_APP_USER /
//  MONGO_APP_PASSWORD) en vez de quedar escritas a mano, para que el
//  .env mande de verdad. Si no estan definidas, se usan los valores
//  por defecto del proyecto, que son los que esperan los microservicios.
// ============================================================

const env = (typeof process !== 'undefined' && process.env) || {};
const appUser = env.MONGO_APP_USER || 'pragma_user';
const appPassword = env.MONGO_APP_PASSWORD || 'pragma_pass';

db = db.getSiblingDB('pragma_trazabilidad');

db.createUser({
  user: appUser,
  pwd: appPassword,
  roles: [{ role: 'readWrite', db: 'pragma_trazabilidad' }]
});

// Coleccion inicial (opcional - Spring la crea on-demand)
db.createCollection('order_logs');

print('[init] base pragma_trazabilidad lista para el usuario ' + appUser);
