import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pembayaranonline/page/panduan.dart';
import 'package:pembayaranonline/page/profile.dart';
import 'package:pembayaranonline/page/RiwayatPage.dart';
import 'package:pembayaranonline/page/tagihan.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    tagihan(),
    ProfilePage(),
    RiwayatPage(),
    Panduan(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Konfirmasi'),
            content: Text('Apakah Anda ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Tidak'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Iya'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _exitApp() async {
    bool shouldExit = await _showExitConfirmationDialog();
    if (shouldExit) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _showExitConfirmationDialog,
      child: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Tagihan',
              backgroundColor: Colors.blue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
              backgroundColor: Colors.blue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat',
              backgroundColor: Colors.blue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.help),
              label: 'Panduan',
              backgroundColor: Colors.blue,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _exitApp,
          child: Icon(Icons.exit_to_app),
        ),
      ),
    );
  }
}
