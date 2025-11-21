import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api.service.dart';
import 'package:image_picker/image_picker.dart';

ValueNotifier<int?> selectedCat = ValueNotifier(null);

class ProductCreate extends StatefulWidget {
  const ProductCreate({super.key});

  @override
  State<ProductCreate> createState() => _ProductCreateState();
}

class _ProductCreateState extends State<ProductCreate> {
  final ApiService api = ApiService();
  final _formKey = GlobalKey<FormState>();

  // controllers
  int? selectedCategory;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController stockCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  // image picker
  List<File> images = [];
  final ImagePicker picker = ImagePicker();

  bool isSaving = false;
  bool loadingCategories = true;

  List<dynamic> categories = [];
  int? kategori;

  // LOAD Category Dari API
  void loadCategories() async {
    final data = await api.getCategories();
    setState(() {
      categories = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCategories();
  }
  // === PILIH GAMBAR ===
  Future pickImages() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => images.add(File(picked.path)));
    }
  }

  // === SIMPAN PRODUK ===
  void doSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (kategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pilih kategori terlebih dahulu")));
      return;
    }

    setState(() => isSaving = true);
    
    final res = await api.saveProduct(
      idKategori: kategori!,
      namaProduk: nameCtrl.text.trim(),
      harga: int.tryParse(priceCtrl.text.trim()) ?? 0,
      stok: int.tryParse(stockCtrl.text.trim()) ?? 0,
      deskripsi: descCtrl.text.trim(),
    );

    if (res["success"] == true) {
      final idProduk = res['data']?['id_produk'] ??
          res['data']?['id'] ??
          res['id_produk'];

      if (idProduk != null) {
        // 2 — Upload foto satu per satu
        for (final img in images) {
          await api.uploadProductImage(
            idProduk: int.parse(idProduk.toString()),
            imageFile: img,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Produk berhasil ditambah")));

        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Gagal simpan produk")),
      );
    }

    setState(() => isSaving = false);
  }

  // === WIDGET INPUT ===
  Widget buildInput(String label, TextEditingController ctrl,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),

        // box input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white24),
          ),
          child: TextFormField(
            controller: ctrl,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Masukkan $label",
              hintStyle: const TextStyle(color: Colors.white38),
              border: InputBorder.none,
            ),
            validator: (v) =>
                v == null || v.isEmpty ? "Masukkan $label" : null,
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Tambah Produk"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // === GRADIENT CYBER ===
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.shade700,
              Colors.black,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<int>(
                  value: kategori,
                  decoration: const InputDecoration(labelText: "Kategori"),
                  items: categories.map<DropdownMenuItem<int>>((cat) {
                    return DropdownMenuItem<int>(
                      value: cat["id_kategori"],
                      child: Text(cat["nama_kategori"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      kategori = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Pilih kategori terlebih dahulu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // === INPUT-FIELD ===
                buildInput("Nama Produk", nameCtrl),
                buildInput("Harga", priceCtrl, isNumber: true),
                buildInput("Stok", stockCtrl, isNumber: true),
                // === DESKRIPSI ===
                const Text("Deskripsi",
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TextFormField(
                    controller: descCtrl,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Masukkan Deskripsi",
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Masukkan deskripsi" : null,
                  ),
                ),
                const SizedBox(height: 20),
                // === GAMBAR PRODUK ===
                const Text("Gambar Produk",
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...images.map((file) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: kIsWeb
                                ? Image.network(
                                    file.path,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    file,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => images.remove(file)),
                              child: Container(
                                color: Colors.black54,
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    // button tambah foto
                    GestureDetector(
                      onTap: pickImages,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: const Center(
                          child: Icon(Icons.add_a_photo,
                              color: Colors.white70, size: 28),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // === BUTTON SIMPAN ===
                Center(
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                          onPressed: doSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("Simpan Produk",
                              style: TextStyle(fontSize: 16)),
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
