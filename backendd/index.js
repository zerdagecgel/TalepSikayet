const express = require('express');
const cors = require('cors');
const path = require('path');
const apiRoutes = require('./routes/API')
require('dotenv').config(); // .env dosyasını kullanmak için dotenv modülünü ekledik
const morgan = require('morgan');

const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');


const app = express();
const port = 3000;
app.use(morgan('dev'));

const sifreRoutes = require('./routes/passwordReset');
const router = require('./routes/API');
  //router.post('/sifre-sifirla',  (req, res) => {});




app.use(cors());
app.use(express.json());

app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'proje')));
app.use(express.static(path.join(__dirname, 'form')));
app.use('/api', sifreRoutes);

// app.use('/api', router); // API rotalarını kullanmak için ekledik



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

