import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});


  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '', email = '', username = '', password = '';

  Future<void> register() async {
    final url = Uri.parse("http://10.33.241.111:3000/register");
 // IP'ni kontrol et
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "name": name,
        "email": email,
        "username": username,
        "password": password,
      }),
    );

    final res = json.decode(response.body);
    if (res["status"] == "success") {
      if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Kayıt başarılı")),
);

      Navigator.pop(context);
    } else {
  final errorMessage = res["message"] ?? "Sunucudan bir hata yanıtı alınamadı.";
  if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Hata: $errorMessage")),
);

}
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kayıt Ol")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Ad Soyad"),
                onSaved: (v) => name = v!,
                validator: (value) =>
                    value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "E-posta"),
                onSaved: (v) => email = v!,
                validator: (value) =>
                    value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Kullanıcı Adı"),
                onSaved: (v) => username = v!,
                validator: (value) =>
                    value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Şifre"),
                obscureText: true,
                onSaved: (v) => password = v!,
                validator: (value) =>
                    value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    register();
                  }
                },
                child: Text("Kayıt Ol"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Şifremi unuttum mesajı
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Bilgi"),
                      content:
                          Text("Şifremi unuttum özelliği henüz aktif değil."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Tamam"),
                        ),
                      ],
                    ),
                  );
                },
                child: Text("Şifremi Unuttum"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
