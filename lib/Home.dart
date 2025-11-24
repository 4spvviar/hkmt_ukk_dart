import 'package:flutter/material.dart';
import 'package:hkmt_ukk_dart/Home(api).dart';
import 'package:hkmt_ukk_dart/Produk.dart';
import 'package:hkmt_ukk_dart/Profile.dart';
import 'package:hkmt_ukk_dart/store_form.dart';
import 'package:hkmt_ukk_dart/store_page.dart';
// Placeholder class untuk setiap halaman
class TokoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StorePage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Index halaman yang dipilih

  // List halaman untuk switch
  final List<Widget> _pages = [
    HomeProdPage(),
    ProdukPage(),
    TokoPage(),
    ProfilePage(),
    StoreFormPage(),
    StorePage(),
  ];

  // Fungsi untuk ganti halaman
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ), // Tampilkan halaman berdasarkan index
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Toko',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex, // Index aktif
        selectedItemColor: Color(0xFFD3D39F), // Warna item aktif
        unselectedItemColor: Color(0xFF493D18), // Warna item tidak aktif
        backgroundColor: Colors.black, // Background nav bar
        onTap: _onItemTapped, // Handler tap
        type: BottomNavigationBarType.fixed, // Fixed untuk 4 item
      ),
    );
  }
}