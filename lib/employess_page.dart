import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
class Complaint {
  final int id;
  final String baslik;
  final String aciklama;
  bool tamamlandi;

  // Yeni ekledim: departman alanı
  final String departman;

  Complaint({
    required this.id,
    required this.baslik,
    required this.aciklama,
    required this.tamamlandi,
    required this.departman,  
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      baslik: json['tur'],
      aciklama: json['aciklama'],
      tamamlandi: json['tamamlandi'] == 1,
      departman: json['adres'],
        
    );
  }
}

class EmployeesPage extends StatefulWidget {
  @override
  _EmployeesPageState createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  List<Complaint> complaints = [];
  bool isLoading = true;
  String filter = 'Tümü';

  // Yeni ekledim: departman listesi ve seçilen departman
  List<String> departments = ['Fen İşleri', 'İmar', 'İnsan Kaynakları', 'Bilgi İşlem'];
  String selectedDepartment = 'Tümü';  // Yeni ekledim

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    setState(() => isLoading = true);
    final url = Uri.parse('http://10.0.2.2:3000/api/complaints');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          complaints = data.map((json) => Complaint.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Veri alınamadı');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Hata: $e');
    }
  }

  Future<void> markAsCompleted(int id) async {
    final url = Uri.parse('http://10.0.2.2:3000/api/complaints/$id');
    try {
      final response = await http.put(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"tamamlandi": 1}));

      if (response.statusCode == 200) {
        setState(() {
          complaints.firstWhere((c) => c.id == id).tamamlandi = true;
        });
      } else {
        throw Exception('Güncelleme başarısız');
      }
    } catch (e) {
      debugPrint('Güncelleme hatası: $e');
    }
  }

  // Güncelledim: departmana göre filtreleme eklendi
  List<Complaint> get filteredComplaints {
    List<Complaint> filtered = complaints;

    // Yeni ekledim: departman filtrelemesi
    if (selectedDepartment != 'Tümü') {
      filtered = filtered.where((c) => c.departman == selectedDepartment).toList();
    }

    if (filter == 'Tamamlanan') {
      filtered = filtered.where((c) => c.tamamlandi).toList();
    } else if (filter == 'Bekleyen') {
      filtered = filtered.where((c) => !c.tamamlandi).toList();
    }
    return filtered;
  }

  Widget buildFilterButton(String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          filter = label;
        });
      },
     
      style: ElevatedButton.styleFrom(
        backgroundColor: filter == label ? Colors.grey[700] : Colors.grey[400],
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Güncelledim: AppBar rengi turuncu yerine gri yapıldı
     appBar: AppBar(
  title: const Text("Talepler/Şikayetler"),
  backgroundColor: const Color.fromARGB(255, 255, 248, 248),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    tooltip: 'Geri',
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    },
  ),
),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Yeni ekledim: Departman seçimi dropdown'u
            DropdownButton<String>(
              value: selectedDepartment,
              items: ['Tümü', ...departments].map((dep) {
                return DropdownMenuItem(
                  value: dep,
                  child: Text(dep),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedDepartment = value;
                  });
                }
              },
            ),

            SizedBox(height: 10),

            // Mevcut: filtre butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildFilterButton("Tümü"),
                buildFilterButton("Bekleyen"),
                buildFilterButton("Tamamlanan"),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredComplaints.isEmpty
                      ? Center(child: Text("Görüntülenecek talep yok"))
                      : ListView.builder(
                          itemCount: filteredComplaints.length,
                          itemBuilder: (context, index) {
                            final complaint = filteredComplaints[index];
                            return Card(
                              color: complaint.tamamlandi ? Colors.green[100] : Colors.red[100],
                              child: ListTile(
                                title: Text(complaint.baslik),
                                subtitle: Text(complaint.aciklama),
                                trailing: complaint.tamamlandi
                                    ? Icon(Icons.check_circle, color: Colors.green)
                                    : ElevatedButton(
                                        child: Text("Tamamlandı"),
                                        onPressed: () => markAsCompleted(complaint.id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[700], // Buton gri oldu
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
