import 'package:flutter/material.dart';
import 'package:toko_ku/AProduk.dart';
import '../api.service.dart';
import 'ProdukD.dart'; // detail produk

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final ApiService api = ApiService();
  bool loading = true;
  List products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  void loadProducts() async {
    final data = await api.getProducts();
    setState(() {
      products = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produk', style: TextStyle(
          color: Colors.blueAccent,
        ),),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductCreate()),
          );

          if (res == true) {
            loadProducts(); // refresh setelah tambah
          }
        },
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (context, i) {
                  final p = products[i];
                  final img = p["images"] ?? [];
                  final imgUrl = img.isNotEmpty ? img[0]["url"] : null;

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetail(productId: p["id_produk"]),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.20),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // GAMBAR PRODUK
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imgUrl != null
                                ? Image.network(
                                    imgUrl,
                                    width: 55,
                                    height: 55,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 55,
                                    height: 55,
                                    color: Colors.white12,
                                    child:
                                        const Icon(Icons.image, color: Colors.white70),
                                  ),
                          ),

                          const SizedBox(width: 14),

                          // TEKS NAMA & HARGA
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p["nama_produk"],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Rp ${p["harga"]}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ICON ARROW
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white54,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}