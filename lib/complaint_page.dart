import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage ({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Talep';
  String? _subject;
  String? _description;

  final List<String> _types = ['Talep', 'Şikayet'];

  // Yeni ekledim: seçilen resim için değişken
  File? _selectedImage;

  // Yeni ekledim: resim seçme fonksiyonu
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talep / Şikayet Gönder'),
        backgroundColor: const Color.fromARGB(255, 53, 145, 182),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tür seçimi
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: _types
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Tür Seçiniz',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              // Konu içeriği
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Konu İçeriği',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konu içeriğini giriniz';
                  }
                  _subject = value;
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Açıklama
              TextFormField(
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Açıklama giriniz';
                  }
                  _description = value;
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Yeni ekledim: Resim seçme butonu
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Resim Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 107, 131, 164),
                ),
              ),

              const SizedBox(height: 10),

              // Yeni ekledim: seçilen resim önizlemesi
              if (_selectedImage != null)
                SizedBox(
                  height: 150,
                  child: Image.file(_selectedImage!),
                ),

              const SizedBox(height: 25),

              // Gönder butonu
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Gönder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 107, 131, 164),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Burada istersen _selectedImage ile resmi backend'e gönderebilirsin

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Gönderildi'),
          content: const Text('Talep/Şikayet başarıyla gönderildi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }
}
