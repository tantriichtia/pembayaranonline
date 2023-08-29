import 'package:flutter/material.dart';
import 'package:pembayaranonline/page/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nisnController = TextEditingController();

  @override
  void dispose() {
    _nisnController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    String nisn = _nisnController.text;

    String url = 'http://tantri.jwnetradius.my.id/API/login.php';

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        body: {
          'nisn': nisn,
        },
      );

      if (response.statusCode == 200) {
        // Login berhasil
        String responseData = response.body;
        var data = json.decode(responseData);

        if (data['success'] == true) {
          // Login sukses
          print('Login berhasil');

          // Simpan NISN ke Shared Preferences
          saveNISNToSharedPreferences(nisn);

          // Lakukan navigasi ke halaman berikutnya
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          // Login gagal
          Fluttertoast.showToast(
            msg: 'Login gagal. Silakan coba lagi.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          print('Login gagal: ${data['message']}');
        }
      } else {
        // Login gagal
        print('Login gagal. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      // Kesalahan saat melakukan permintaan
      print('Terjadi kesalahan: $e');
    }
  }

  Future<void> saveNISNToSharedPreferences(String nisn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('nisn', nisn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                  'https://img001.prntscr.com/file/img001/ZYQK32ENQbC5q99iPLlEXA.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.fill),
              SizedBox(height: 20),
              TextField(
                controller: _nisnController,
                decoration: InputDecoration(
                  hintText: 'Masukkan NISN',
                  labelText: 'NISN',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              SizedBox(height: 60),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
