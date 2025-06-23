import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
 // key parametresi eklendi

  @override
  _LoginPageState createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? username;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 100),
                TextFormField(
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                    labelText: 'Kullanıcı Adı',
                    labelStyle: TextStyle(color: Colors.deepOrange),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kullanıcı adını giriniz';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    username = value ?? '';
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                    labelText: 'Şifre',
                    labelStyle: TextStyle(color: Colors.deepOrange),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifrenizi giriniz';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    password = value ?? '';
                  },
                ),
                SizedBox(height: 20.0),
                _loginButton(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _registerButton(),
                    _forgotPasswordButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginButton() => ElevatedButton(
        child: Text("Giriş Yap"),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            login();
          }
        },
      );
      

  Widget _registerButton() => ElevatedButton(
        child: Text("Üye Ol"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterPage()),
          );
        },
      );

  Widget _forgotPasswordButton() => ElevatedButton(
        child: Text("Şifremi Unuttum"),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Bilgi"),
              content: Text("Şifremi unuttum özelliği henüz aktif değil."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Tamam"),
                ),
              ],
            ),
          );
        },
      );

  Future<void> login() async {
    final url = Uri.parse("http://10.0.2.2:3000/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "kullanici_adi": username,
          "sifre": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (data["basarili"] == true) {
        debugPrint("Giriş başarılı: $username");
        // Başarılıysa yönlendirme eklenebilir
      } else {
        _showErrorDialog(data["mesaj"] ?? "Kullanıcı bilgileriniz hatalı!");
      }
    } catch (e) {
      _showErrorDialog("Sunucuya bağlanılamadı: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Hata"),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("Tamam"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
