import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? newPassword;
  String? confirmPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Şifremi Unuttum'),
        backgroundColor: const Color.fromARGB(255, 91, 87, 87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ✅ E-posta Alanı
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen e-posta adresinizi giriniz';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Geçerli bir e-posta adresi giriniz';
                  }
                  email = value;
                  return null;
                },
              ),
              SizedBox(height: 20),

              // ✅ Yeni Şifre Alanı
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen yeni şifrenizi giriniz';
                  }
                  newPassword = value;
                  return null;
                },
              ),
              SizedBox(height: 20),

              // ✅ Yeni Şifre (Tekrar) Alanı
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre (Tekrar)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifreyi tekrar giriniz';
                  }
                  if (value != newPassword) {
                    return 'Şifreler eşleşmiyor';
                  }
                  confirmPassword = value;
                  return null;
                },
              ),
              SizedBox(height: 30),

              // ✅ Şifreyi Değiştir Butonu
              ElevatedButton(
                onPressed: _resetPassword,
                child: Text('Şifreyi Değiştir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 42, 23, 146)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Şifre Değiştir Fonksiyonu (Backend'e istek gönderir)
  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/reset-password'), // Backend URL
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": email,
            "newPassword": newPassword,
          }),
        );

        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          _showSuccessDialog("Şifre değiştirme işlemi başarılı.");
        } else {
          _showErrorDialog(data['message'] ?? 'Bir hata oluştu.');
        }
      } catch (e) {
        _showErrorDialog("Sunucuya bağlanılamadı: $e");
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Başarılı"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog kapat
              Navigator.pop(context); // login sayfasına dön
            },
            child: Text("Tamam"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hata"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tamam"),
          ),
        ],
      ),
    );
  }
}
 