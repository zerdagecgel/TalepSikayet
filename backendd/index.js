const express = require('express');
const cors = require('cors');
const path = require('path');
const apiRoutes = require('./routes/API')
require('dotenv').config(); // .env dosyasını kullanmak için dotenv modülünü ekledik




const app = express();
const port = 3000;


  


app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'proje')));
app.use(express.static(path.join(__dirname, 'form')));


app.get('/', (req, res) => {
  res.status(200).send({ message: 'Merhaba, bu bir Node.js uygulamasıdır!' });
});
app.use('/api', apiRoutes);
app.listen(port, () => {
  console.log(`Sunucu http://localhost:${port} üzerinde çalışıyor`);
});
app.use((err, req, res, next) => {
  console.error("HATA:", err.stack);
  res.status(500).json({ status: 'error', message: 'Sunucu hatası!' });
});