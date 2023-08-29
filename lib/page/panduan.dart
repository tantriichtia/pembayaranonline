import 'package:flutter/material.dart';

class Panduan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panduan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cara menggunakan aplikasi:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              '1. Pilih menu Tagihan untuk melihat daftar transaksi yang perlu dibayar.',
            ),
            SizedBox(height: 8.0),
            Text(
              '2. Pilih menu Profile untuk melihat informasi pribadi Anda.',
            ),
            SizedBox(height: 8.0),
            Text(
              '3. Pilih menu Riwayat Pembayaran untuk melihat riwayat transaksi yang telah dilakukan.',
            ),
            SizedBox(height: 8.0),
            Text(
              '4. Pilih menu Panduan untuk melihat petunjuk penggunaan aplikasi ini.',
            ),
          ],
        ),
      ),
    );
  }
}
