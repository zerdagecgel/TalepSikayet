const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const validator = require('validator');
const authenticateToken = require('../middleware/auth');
const connection = require('../config/db');
require('dotenv').config();
const SECRET_KEY = process.env.JWT_SECRET;

  function hataYaniti(res, mesaj = "Sunucu hatası") {
  return res.status(500).json({ status: "error", message: mesaj });
}
// Kayıt ol endpoint
  router.post('/register', (req, res) => {
  const { kullanici_adi, sifre, eposta, tam_adi, telefon } = req.body;

  if (!kullanici_adi || !sifre || !eposta || !tam_adi) {
    return res.status(400).json({ status: "error", message: "Lütfen tüm zorunlu alanları doldurun." });
  }
  if (!validator.isEmail(eposta)) {
    return res.status(400).json({ status: "error", message: "Geçerli bir e-posta girin." });
  }
  const sifreRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[^\s]{8,}$/;
  if (!sifreRegex.test(sifre)) {
    return res.status(400).json({ status: "error", message: "Şifre en az 6 karakter, 1 büyük harf, 1 küçük harf ve 1 sayı içermeli. Boşluk içeremez." });
  }
  const kullaniciRegex = /^[a-zA-Z0-9]{4,}$/;
  if (!kullaniciRegex.test(kullanici_adi)) {
    return res.status(400).json({ status: "error", message: "Kullanıcı adı en az 4 karakter ve sadece harf/rakam içermeli." });
  }

  const kontrolQuery = "SELECT * FROM kullanici WHERE kullanici_adi = ? OR eposta = ?";
  connection.query(kontrolQuery, [kullanici_adi, eposta], (err, result) => {
    if (err) return res.status(500).json({ status: "error", message: "Veritabanı hatası." });

    if (result.length > 0) {
      return res.status(409).json({ status: "error", message: "Bu kullanıcı adı veya e-posta zaten kayıtlı." });
    }

    bcrypt.hash(sifre, 10, (err, hash) => {
      if (err) return res.status(500).json({ status: "error", message: "Şifre işlenemedi." });

      const kayitQuery = 'INSERT INTO kullanici (kullanici_adi, sifre_hash, eposta, tam_adi, telefon) VALUES (?, ?, ?, ?, ?)';
      connection.query(kayitQuery, [kullanici_adi, hash, eposta, tam_adi, telefon || null], (err, result) => {
        if (err) return res.status(500).json({ status: "error", message: "Kayıt sırasında hata oluştu." });

        return res.json({ status: "success", message: "Kayıt başarılı!" });
      });
    });
  });
});

// Giriş endpoint
router.post('/login', (req, res) => {
  const { kullanici_adi, sifre } = req.body;
  console.log("Giriş isteği alındı:", { kullanici_adi, sifre });

  if (!kullanici_adi || !sifre) {
    return res.status(400).json({ basarili: false, mesaj: "Kullanıcı adı ve şifre gereklidir." });
  }

  const sorgu = "SELECT * FROM kullanici WHERE kullanici_adi = ?";
  connection.query(sorgu, [kullanici_adi], (err, results) => {
    if (err) {
      console.error("Veritabanı hatası:", err);
      return res.status(500).json({ basarili: false, mesaj: "Sunucu hatası." });
    }

    if (results.length === 0) {
      return res.json({ basarili: false, mesaj: "Kullanıcı bulunamadı." });
    }

    const user = results[0];

    bcrypt.compare(sifre, user.sifre_hash, (err, isMatch) => {
      if (err) {
        console.error("Şifre kontrol hatası:", err);
        return res.status(500).json({ basarili: false, mesaj: "Sunucu hatası." });
      }

      if (isMatch) {
      const token = jwt.sign(
    { id: user.id, kullanici_adi: user.kullanici_adi },
    process.env.JWT_SECRET, //Burası sabit değil .env'den alınıyor
    { expiresIn: '2h' })
    
    return res.status(200).json({ basarili: true, token: token, mesaj: "Giriş başarılı." });
 
      } else {
        return res.status(401).json({ basarili: false, mesaj: "Şifre yanlış." });
      }
    });
  });
});

// Kayıtlı kullanıcıları getir (örneğin admin için)
router.get('/kullanici', (req, res) => {
  connection.query('SELECT * FROM kullanici', (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results);
  });
});

// Korunması gereken veri ekleme endpointi (token ile)
router.post('/veri-ekle', authenticateToken, (req, res) => {
  const { basvuru_no, basvuru_tipi, icerik, isim, soyisim, adres, basvuru_durumu } = req.body;

  if (!basvuru_no || !basvuru_tipi || !icerik || !isim || !soyisim || !adres || !basvuru_durumu) {
    return res.status(400).json({ status: "error", message: "Lütfen tüm alanları doldurun." });
  }

  const ekleQuery = `
    INSERT INTO veriler (basvuru_no, basvuru_tipi, icerik, isim, soyisim, adres, basvuru_durumu)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `;

  connection.query(ekleQuery, [basvuru_no, basvuru_tipi, icerik, isim, soyisim, adres, basvuru_durumu], (err, result) => {
    if (err) {
      console.error("Veritabanı hatası:", err);
      return res.status(500).json({ status: "error", message: "Veri eklenemedi." });
    }

    return res.json({ status: "success", message: "Başvuru başarıyla kaydedildi.", id: result.insertId });
  });
});

// Tüm verileri listele
router.get('/veriler', (req, res) => {
  connection.query('SELECT * FROM veriler', (err, results) => {
    if (err) return res.status(500).json({ status: "error", message: "Veri çekilemedi" });
    res.json(results);
  });
});

// Başvuru durumu güncelle
router.put('/veri-guncelle/:id', (req, res) => {
  const { basvuru_durumu } = req.body;
  const { id } = req.params;

  const query = 'UPDATE veriler SET basvuru_durumu = ? WHERE id = ?';
  connection.query(query, [basvuru_durumu, id], (err, result) => {
    if (err) return res.status(500).json({ status: "error", message: "Güncelleme hatası" });
    res.json({ status: "success", message: "Başvuru durumu güncellendi" });
  });
});

// Başvuru sil
router.delete('/veri-sil/:id', (req, res) => {
  const { id } = req.params;

  const query = 'DELETE FROM veriler WHERE id = ?';
  connection.query(query, [id], (err, result) => {
    if (err) return res.status(500).json({ status: "error", message: "Silme hatası" });
    res.json({ status: "success", message: "Başvuru silindi" });
  });
});

module.exports = router;
