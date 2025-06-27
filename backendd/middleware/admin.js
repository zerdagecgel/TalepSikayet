 //Bu dosya bir middleware fonksiyonu export eder. 
  
  module.exports = (req, res, next) => {
    if (req.user?.rol === 'admin') {
      return next();
    }
    return res.status(403).json({ mesaj: "Yetkisiz erişim" });
  };

// Bu middleware, kullanıcının admin rolüne sahip olup olmadığını kontrol eder.Express middleware → req, res, next parametreli.

//req.user → Auth middleware’den gelir.

//rol kontrolü → admin mi değil mi?

//Adminse → next() ile devam.

//Değilse → 403 Forbidden JSON mesajı.