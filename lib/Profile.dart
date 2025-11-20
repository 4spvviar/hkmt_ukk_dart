import 'package:flutter/material.dart';
import 'package:toko_ku/api.service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ApiService api = ApiService();
  bool isLoading = true;
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    final data = await api.getUser();
    print("PROFILE RESPONSE: $data"); // debug

    if (mounted) {
      setState(() {
        profile = data["data"];   // <--- INI YANG PALING PENTING
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profile == null) {
      return const Center(child: Text("Gagal memuat data profil"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama: ${profile!['nama']}", style: const TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Username: ${profile!['username']}", style: const TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Kontak: ${profile!['kontak']}", style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
