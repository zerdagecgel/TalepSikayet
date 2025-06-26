    const jwt = require('jsonwebtoken');
    require('dotenv').config();
    const JWT_SECRET = process.env.JWT_SECRET;


    function authenticateToken(req, res, next) {
    // Header’dan token alıyoruz: Authorization: Bearer <token>
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
    return res.status(401).json({ basarili: false, mesaj: 'Token bulunamadı, erişim reddedildi.' });
    }

    jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
        return res.status(403).json({ basarili: false, mesaj: 'Token geçersiz veya süresi dolmuş.' });
    }
    req.user = user; // İstersen user bilgisini request objesine ekle
    next();
    });
}

module.exports = authenticateToken;
