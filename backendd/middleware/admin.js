module.exports = function(req, res, next) {
  if (req.user && req.user.rol === 'admin') {
    next();
  } else {
    return res.status(403).json({ mesaj: "Yetkisiz erişim" });
  }
};
