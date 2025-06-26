const mysql = require('mysql');
require('dotenv').config();

const connection = mysql.createPool({
  connectionLimit: 10,
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

connection.getConnection((err) => {
  if (err) {
    console.error('MySQL bağlantı hatası:', err);
  } else {
    console.log('MySQL bağlantısı başarılı.');
  }
});

module.exports = connection;
