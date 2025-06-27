const express = require('express');
const router = express.Router();
const db = require('../config/db');
const { authenticateToken, authorizeAdmin } = require('../middleware/auth');

// Giriş yapmış tüm kullanıcılar
router.get('/kullanici-bilgisi', authenticateToken, (req, res) => {
  res.json({ mesaj: 'Token geçerli', kullanici: req.user });
});

// Sadece admin kullanıcılar
router.get('/kullanicilar', authenticateToken, authorizeAdmin, (req, res) => {
  const query = 'SELECT id, kullanici_adi, eposta, rol FROM kullanici';
  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ basarili: false, mesaj: 'Veri çekilemedi' });
    }
    res.json({ basarili: true, kullanicilar: results });
  });
});

module.exports = router;




//JWT doğrulama ve admin yetkisi kontrolü middleware’lerini kullanıyor.

//kullanici-bilgisi → sadece giriş yapan kullanıcı görebilir, kendi bilgisi döner.

//kullanicilar → sadece admin kullanıcılar tüm kullanıcıları listeler.

//MySQL sorgusunu db.query ile yapıyor.