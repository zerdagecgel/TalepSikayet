const jwt = require('jsonwebtoken');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET;

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ basarili: false, mesaj: 'Token bulunamadı, erişim reddedildi.' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ basarili: false, mesaj: 'Token geçersiz veya süresi dolmuş.' });
    }
    req.user = user;
    next();
  });
};

module.exports = authenticateToken;


// Bu middleware, gelen isteklerdeki JWT token'ı doğrular.Authorization header'daki Bearer token'ı alır.

//Token'ı verify eder.

//Doğruysa → req.user içine kullanıcı bilgisi ekler, devam eder.

//Yanlış / eksikse → 401 veya 403 döner.