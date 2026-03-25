// ============================================================
//  MongoDB init script – ejecutado al primer arranque
//  Crea la base de datos de trazabilidad y un usuario de app.
// ============================================================

db = db.getSiblingDB('pragma_trazabilidad');

db.createUser({
  user: 'pragma_user',
  pwd: 'pragma_pass',
  roles: [{ role: 'readWrite', db: 'pragma_trazabilidad' }]
});

// Colección inicial (opcional – Spring la crea on-demand)
db.createCollection('order_logs');

