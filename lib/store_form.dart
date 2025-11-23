import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toko_ku/api.service.dart';

class StoreFormPage extends StatefulWidget {
  const StoreFormPage({super.key});

  @override
  _StoreFormPageState createState() => _StoreFormPageState();
}

class _StoreFormPageState extends State<StoreFormPage> {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final waCtrl = TextEditingController();

  File? logoFile;
  Map<String, dynamic>? store;
  bool isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    store = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (store != null) {
      nameCtrl.text = store!["nama_toko"] ?? "";
      descCtrl.text = store!["deskripsi"] ?? "";
      addressCtrl.text = store!["kontak_toko"] ?? "";
      waCtrl.text = store!["alamat"] ?? "";
    }
  }

  Future<void> pickLogo() async {
    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: ImageSource.gallery);
      if (img != null) {
        setState(() => logoFile = File(img.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    print("Submitting store with data: name='${nameCtrl.text}', description='${descCtrl.text}', address='${addressCtrl.text}', whatsapp='${waCtrl.text}', logo file: $logoFile");

    setState(() {
      isSubmitting = true;
    });

      final response = await ApiService().saveStore(
        {
          "nama_toko": nameCtrl.text.trim(),
          "deskripsi": descCtrl.text.trim(),
          "kontak_toko": addressCtrl.text.trim(),
          "alamat": waCtrl.text.trim(),
        },
        image: logoFile, // keep param name unchanged here as it maps to 'gambar' in API service
      );


    setState(() {
      isSubmitting = false;
    });

    if (response["success"] != null && response["success"] == true) {
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      final message = response["message"] ?? "Gagal menyimpan toko";
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    addressCtrl.dispose();
    waCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(store == null ? "Buat Toko" : "Edit Toko"),
        backgroundColor: const Color(0xFF493D18),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF493D18),
              Colors.black,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                TextFormField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Nama Toko",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Nama toko harus diisi";
                  }
                  return null;
                },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Deskripsi",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Alamat",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: waCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Nomor WhatsApp",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isSubmitting ? null : pickLogo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD3D39F),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Upload Logo",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (logoFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.file(logoFile!, height: 120),
                  ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isSubmitting ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD3D39F),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          "Simpan",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
