import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'register_page.dart';
import 'forgot_password.dart';
import 'complaint_page.dart';
import 'employess_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? username;
  String? password;
  String? rol;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                Image.asset(
                  'assets/mezitbellogo.png', 
                  height: 100,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    labelText: 'Kullanıcı Adı',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 170, 171, 172)),
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
                const SizedBox(height: 10.0),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    labelText: 'Şifre',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 170, 171, 172)),
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
                const SizedBox(height: 20.0),
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
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
        ),
        child: const Text("Giriş Yap"),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            final rol = await login();
            debugPrint("Gelen rol: $rol");

            if (!context.mounted) return;

            if (rol == 'admin') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmployeesPage()),
              );
            } else if (rol == 'user') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ComplaintPage()),
              );
            } else if (rol == null) {
              // zaten hata gösterildi
            } else {
              _showErrorDialog("Tanımsız kullanıcı rolü: $rol");
            }
          }
        },
      );

  Widget _registerButton() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
        ),
        child: const Text("Kayıt Ol"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterPage()),
          );
        },
      );

  Widget _forgotPasswordButton() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
        ),
        child: const Text("Şifremi Unuttum"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
          );
        },
      );

  Future<String?> login() async {
    final url = Uri.parse("http://10.0.2.2:3000/api/login");

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
        return data["rol"] ?? "user";
      } else {
        _showErrorDialog(data["mesaj"] ?? "Kullanıcı bilgileriniz hatalı!");
        return null;
      }
    } catch (e) {
      _showErrorDialog("Sunucuya bağlanılamadı: $e");
      return null;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Hata"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Tamam"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
