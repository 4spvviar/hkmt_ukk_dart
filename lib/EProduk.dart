import 'package:flutter/material.dart';
import '../api.service.dart';

class ProductEdit extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductEdit({super.key, required this.product});

  @override
  State<ProductEdit> createState() => _ProductEditState();
}

class _ProductEditState extends State<ProductEdit> {
  final ApiService api = ApiService();
  final _formKey = GlobalKey<FormState>();

  late int selectedCategory;
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController stockCtrl;
  late TextEditingController descCtrl;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    selectedCategory = int.tryParse(p['id_kategori']?.toString() ?? '0') ?? 0;
    nameCtrl = TextEditingController(text: p['nama_produk'] ?? '');
    priceCtrl = TextEditingController(text: p['harga']?.toString() ?? '');
    stockCtrl = TextEditingController(text: p['stok']?.toString() ?? '');
    descCtrl = TextEditingController(text: p['deskripsi'] ?? '');
  }

  void doUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(()=> isSaving = true);

    final res = await api.saveProduct(
      idProduk: int.tryParse(widget.product['id_produk'].toString()),
      idKategori: selectedCategory,
      namaProduk: nameCtrl.text.trim(),
      harga: int.tryParse(priceCtrl.text.trim()) ?? 0,
      stok: int.tryParse(stockCtrl.text.trim()) ?? 0,
      deskripsi: descCtrl.text.trim(),
    );

    setState(()=> isSaving = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil diupdate')));
      Navigator.pop(context, true); // kembali ke detail
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal update')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Elektronik')),
                  DropdownMenuItem(value: 3, child: Text('Seragam')),
                  DropdownMenuItem(value: 4, child: Text('ATK')),
                  DropdownMenuItem(value: 7, child: Text('Hardware')),
                ],
                value: selectedCategory == 0 ? null : selectedCategory,
                onChanged: (v) => setState(()=> selectedCategory = v ?? selectedCategory),
                validator: (v) => v == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Produk'), validator: (v)=> v==null||v.isEmpty? 'Masukkan nama':null),
              const SizedBox(height: 12),
              TextFormField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number, validator: (v)=> v==null||v.isEmpty? 'Masukkan harga':null),
              const SizedBox(height: 12),
              TextFormField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number, validator: (v)=> v==null||v.isEmpty? 'Masukkan stok':null),
              const SizedBox(height: 12),
              TextFormField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi'), maxLines: 5, validator: (v)=> v==null||v.isEmpty? 'Masukkan deskripsi':null),
              const SizedBox(height: 20),
              isSaving ? const CircularProgressIndicator() : ElevatedButton(onPressed: doUpdate, child: const Text('Update Produk')),
            ],
          ),
        ),
      ),
    );
  }
}
