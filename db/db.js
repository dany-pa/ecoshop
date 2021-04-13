const { Pool } = require('pg');
let db = undefined;
if (process.env.DATABASE_URL){
    db = new Pool({
        connectionString: process.env.DATABASE_URL,
        ssl: {
            rejectUnauthorized: false
        }
    });
} else {
    const config = require('../private/dbConfig.js');
    db = new Pool({
        host: config.host,
        user: config.user,
        password: config.password,
        database: config.database,
        port: config.port,
        ssl: false,
    });
}

module.exports = db;