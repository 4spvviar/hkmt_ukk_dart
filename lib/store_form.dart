import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hkmt_ukk_dart/api.service.dart';

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

  XFile? pickedImage;
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
      addressCtrl.text = store!["alamat"] ?? "";
      waCtrl.text = store!["kontak_toko"] ?? "";
    }
  }

  Future<void> pickLogo() async {
    try {
      final img = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (img != null) {
        setState(() {
          pickedImage = img;
          if (!kIsWeb) {
            logoFile = File(img.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memilih gambar: $e")),
      );
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    Map<String, dynamic> response;

    // ========= HANDLE WEB =========
    if (kIsWeb && pickedImage != null) {
      final bytes = await pickedImage!.readAsBytes();
      response = await ApiService().saveStoreWeb(
        {
          "nama_toko": nameCtrl.text.trim(),
          "deskripsi": descCtrl.text.trim(),
          "alamat": addressCtrl.text.trim(),
          "kontak_toko": waCtrl.text.trim(),
        },
        bytes: bytes,
        filename: pickedImage!.name,
      );
    }
    // ========= HANDLE MOBILE =========
    else {
      response = await ApiService().saveStoreWeb(
        {
          "nama_toko": nameCtrl.text.trim(),
          "deskripsi": descCtrl.text.trim(),
          "alamat": addressCtrl.text.trim(),
          "kontak_toko": waCtrl.text.trim(),
        },
        bytes: await logoFile!.readAsBytes(),
        filename: logoFile!.path.split("/").last,
      );
    }

    setState(() => isSubmitting = false);

    if (response["success"] == true) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Gagal menyimpan toko")),
      );
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
            colors: [Color(0xFF493D18), Colors.black],
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
                // NAMA TOKO
                TextFormField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputStyle("Nama Toko"),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Nama toko harus diisi" : null,
                ),
                const SizedBox(height: 12),

                // DESKRIPSI
                TextFormField(
                  controller: descCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputStyle("Deskripsi"),
                ),
                const SizedBox(height: 12),

                // ALAMAT
                TextFormField(
                  controller: addressCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputStyle("Alamat"),
                ),
                const SizedBox(height: 12),

                // KONTAK
                TextFormField(
                  controller: waCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputStyle("Kontak Toko"),
                ),
                const SizedBox(height: 20),

                // UPLOAD BUTTON
                ElevatedButton(
                  onPressed: isSubmitting ? null : pickLogo,
                  style: btnStyle(),
                  child: const Text("Upload Logo",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),

                // PREVIEW GAMBAR
                if (pickedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: kIsWeb
                        ? Image.network(pickedImage!.path, height: 120)
                        : Image.file(File(pickedImage!.path), height: 120),
                  ),

                const SizedBox(height: 30),

                // TOMBOL SIMPAN
                ElevatedButton(
                  onPressed: isSubmitting ? null : submit,
                  style: btnStyle(),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
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

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
    );
  }

  ButtonStyle btnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFD3D39F),
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }
}
