// // sqflite_sw.js
// importScripts('https://unpkg.com/sql.js@1.8.0/dist/sql-wasm.js');

// let SQL;
// let databases = new Map();

// async function initSqlJs() {
//   if (!SQL) {
//     SQL = await initSqlJs({
//       locateFile: file => `https://unpkg.com/sql.js@1.8.0/dist/${file}`
//     });
//   }
//   return SQL;
// }

// self.addEventListener('message', async (event) => {
//   const { id, method, args } = event.data;
  
//   try {
//     await initSqlJs();
    
//     let result;
//     switch (method) {
//       case 'openDatabase':
//         result = await openDatabase(...args);
//         break;
//       case 'execute':
//         result = await execute(...args);
//         break;
//       case 'query':
//         result = await query(...args);
//         break;
//       case 'close':
//         result = await closeDatabase(...args);
//         break;
//       default:
//         throw new Error(`Unknown method: ${method}`);
//     }
    
//     self.postMessage({ id, result });
//   } catch (error) {
//     self.postMessage({ id, error: error.message });
//   }
// });

// async function openDatabase(path, version) {
//   if (!databases.has(path)) {
//     const db = new SQL.Database();
//     databases.set(path, db);
//   }
//   return { path, version };
// }

// async function execute(path, sql, parameters = []) {
//   const db = databases.get(path);
//   if (!db) {
//     throw new Error(`Database not found: ${path}`);
//   }
  
//   const stmt = db.prepare(sql);
//   if (parameters.length > 0) {
//     stmt.bind(parameters);
//   }
  
//   const result = [];
//   while (stmt.step()) {
//     const row = stmt.getAsObject();
//     result.push(row);
//   }
//   stmt.free();
  
//   return result;
// }

// async function query(path, sql, parameters = []) {
//   return await execute(path, sql, parameters);
// }

// async function closeDatabase(path) {
//   const db = databases.get(path);
//   if (db) {
//     db.close();
//     databases.delete(path);
//   }
//   return true;
// }