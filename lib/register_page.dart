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
  String name = '';
  String email = '';
  String username = '';
  String password = '';
  

  Future<void> register() async {
    final url = Uri.parse("http://10.0.2.2:3000/api/register"); // IP'ni kontrol et
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "tam_adi": name,
        "eposta": email,
        "kullanici_adi": username,
        "sifre": password,
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
      appBar: AppBar(
        title: Text("Kayıt Ol"),
        backgroundColor: Color.fromARGB(255, 99, 156, 213),
        ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Ad Soyad"),
                onSaved: (value) => name = value!,
                validator: (value) => value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "E-posta"),
                onSaved: (value) => email = value!,
                validator: (value) => value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Kullanıcı Adı"),
                onSaved: (value) => username = value!,
                validator: (value) => value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Şifre"),
                obscureText: true,
                onSaved: (value) => password = value!,
                validator: (value) => value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    register();
                  }
                },
                 style: ElevatedButton.styleFrom(
    foregroundColor: Colors.black, // yazı rengini siyah yap
  ),
                child: Text("Kayıt Ol"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
