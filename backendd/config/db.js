const mysql = require('mysql');
require('dotenv').config();

// Bağlantı havuzu oluştur
const pool = mysql.createPool({
  connectionLimit: 10,
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Bağlantıyı test et
pool.getConnection((err, connection) => {
  if (err) {
    console.error('MySQL bağlantı hatası:', err.message);
  } else {
    console.log('MySQL bağlantısı başarılı.');
    connection.release();
  }
});

// Dışa aktar
module.exports = pool;
// Bu kod, MySQL veritabanına bağlantı kurmak için bir bağlantı havuzu oluşturur.