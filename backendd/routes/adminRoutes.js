const express = require('express');
const router = express.Router();
const db = require('../config/db');
const { authenticateToken, authorizeAdmin } = require('../middleware/auth');


// Sadece giriş yapılmış kullanıcılar erişebilir:
router.get('/kullanici-bilgisi', authenticateToken, (req, res) => {
  res.json({ mesaj: 'Token geçerli', kullanici: req.user });
});

// Sadece admin kullanıcılar erişebilir
router.get('/kullanicilar', authenticateToken, authorizeAdmin, (req, res) => {
  const query = 'SELECT id, kullanici_adi, eposta, rol FROM kullanici';
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ basarili: false, mesaj: 'Veri çekilemedi' });
    res.json({ basarili: true, kullanicilar: results });
  });
});

module.exports = router;
