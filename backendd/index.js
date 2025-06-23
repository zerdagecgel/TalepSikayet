const express = require('express');
const mysql = require('mysql');
const cors = require('cors');
const path = require('path');

const app = express();
const port = 3000;


app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'proje')));



const connection = mysql.createConnection({
  host: '10.33.22.208',
  user: 'root',
  password: 'Bel33.Mez33',
  database: 'talep'
});

connection.connect(err => {
  if (err) {
    console.error('MySQL bağlantı hatası:', err);
  } else {
    console.log('MySQL bağlantısı başarılı.');
  }
});


// Kullanıcıları getiren endpoint
app.get('/kullanici', (req, res) => {
  const query = 'SELECT *  FROM kullanici';
  connection.query(query, (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results);
  });
});



// Kayıt endpoint'i
app.post('/register', (req, res) => {
  const { kullanici_adi, sifre, eposta, tam_adi, telefon } = req.body;

  if (!kullanici_adi || !sifre || !eposta || !tam_adi) {
    return res.status(400).json({
      status: "error",
      message: "Lütfen zorunlu alanları doldurun."
    });
  }

  const query = 'INSERT INTO kullanici (kullanici_adi, sifre_hash, eposta, tam_adi, telefon) VALUES (?, ?, ?, ?, ?)';

  connection.query(query, [kullanici_adi, sifre, eposta, tam_adi, telefon || null], (err, result) => {
    if (err) {
      console.error('Veritabanı hatası:', err);
      return res.status(500).json({
        status: "error",
        message: "Kayıt sırasında hata oluştu."
      });
    }

    return res.json({
      status: "success",
      message: "Kayıt başarılı!"
    });
  });
});



app.post('/login', (req, res) => {
  const { kullanici_adi, sifre } = req.body;

  if (!kullanici_adi || !sifre) {
    return res.status(400).json({ basarili: false, mesaj: "Kullanıcı adı ve şifre gereklidir." });
  }

  const sorgu = "SELECT * FROM kullanici WHERE kullanici_adi = ? AND sifre_hash = ?";

  connection.query(sorgu, [kullanici_adi, sifre], (err, results) => {
    if (err) {
      console.error("Veritabanı hatası:", err);
      return res.status(500).json({ basarili: false, mesaj: "Sunucu hatası." });
    }

    if (results.length > 0) {
      res.json({ basarili: true, mesaj: "Giriş başarılı." });
    } else {
      res.json({ basarili: false, mesaj: "Kullanıcı adı veya şifre hatalı." });
    }
  });
});

// Sunucu başlatma
app.listen(port, () => {
  console.log(`Sunucu http://localhost:${port} üzerinde çalışıyor`);
});
