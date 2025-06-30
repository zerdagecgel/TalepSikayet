// routes/passwordReset.js

const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const connection = require('../config/db');



/**
 * @swagger
 * tags:
 *   name: Şifre
 *   description: Şifre sıfırlama işlemleri
 */

/**
 * @swagger
 * /sifre-sifirla:
 *   post:
 *     summary: Kullanıcının şifresini sıfırlar
 *     tags: [Şifre]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - kullanici_adi
 *               - yeni_sifre
 *             properties:
 *               kullanici_adi:
 *                 type: string
 *                 example: kullanici1
 *               yeni_sifre:
 *                 type: string
 *                 example: Test1234
 *     responses:
 *       200:
 *         description: Şifre başarıyla sıfırlandı.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 mesaj:
 *                   type: string
 *                   example: Şifre başarıyla sıfırlandı.
 *       400:
 *         description: Eksik veya hatalı parametreler.
 *       404:
 *         description: Kullanıcı bulunamadı.
 *       500:
 *         description: Sunucu hatası.
 */



// Şifre sıfırlama endpoint
router.post('/sifre-sifirla', (req, res) => {
  const { kullanici_adi, yeni_sifre } = req.body;
console.log(kullanici_adi,yeni_sifre)
  if (!kullanici_adi || !yeni_sifre) {
    return res.status(400).json({ mesaj: 'Kullanıcı adı ve yeni şifre gerekli.' });
  }

  const sifreRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[^\s]{6,}$/;
  if (!sifreRegex.test(yeni_sifre)) {
    return res.status(400).json({ mesaj: 'Şifre güçlü değil. Büyük harf, küçük harf ve sayı içermeli.' });
  }

  connection.query('SELECT * FROM kullanici WHERE kullanici_adi = ?', [kullanici_adi], (err, results) => {
    if (err || results.length === 0) {
      return res.status(404).json({ mesaj: 'Kullanıcı bulunamadı.' });
    }

    bcrypt.hash(yeni_sifre, 10, (err, hash) => {
      if (err) return res.status(500).json({ mesaj: 'Şifre hashlenemedi.' });

      connection.query('UPDATE kullanici SET sifre_hash = ? WHERE kullanici_adi = ?', [hash, kullanici_adi], (err) => {
        if (err) return res.status(500).json({ mesaj: 'Şifre güncellenemedi.' });

        res.json({ success:true,mesaj: 'Şifre başarıyla sıfırlandı.' });
      });
    });
  });
});

module.exports = router;
