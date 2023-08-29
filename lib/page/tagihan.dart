import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pembayaranonline/page/methode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class tagihan extends StatefulWidget {
  @override
  _tagihanState createState() => _tagihanState();
}

class _tagihanState extends State<tagihan> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> bills = [];
  late String nisn; // Menyimpan nilai NISN dari shared preferences

  Future<List<Map<String, dynamic>>> fetchBills() async {
    final response = await http.get(Uri.parse(
        'https://tantri.jwnetradius.my.id/API/tagih.php?nisn=$nisn')); // Menggunakan nilai NISN dalam URL
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to fetch bills');
    }
  }

  @override
  void initState() {
    super.initState();
    getNISNFromSharedPreferences().then((value) {
      setState(() {
        nisn = value;
      });
      fetchBills().then((data) {
        setState(() {
          bills = data;
          _tabController = TabController(length: bills.length, vsync: this);
        });
      }).catchError((error) {
        print('Error: $error');
      });
    });
  }

  Future<String> getNISNFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nisn') ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void payBill(int amount, bill) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PaymentPage(nisn: nisn, amount: amount, title: bill)));
  }

  String formatCurrency(int amount) {
    var formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagihan'),
        bottom: bills.isNotEmpty
            ? TabBar(
                controller: _tabController,
                tabs: bills.map<Widget>((bill) {
                  return Tab(
                    text: bill['title'],
                  );
                }).toList(),
              )
            : null,
      ),
      body: bills.isNotEmpty
          ? TabBarView(
              controller: _tabController,
              children: bills.map<Widget>((bill) {
                return BillItem(
                  title: bill['title'],
                  amount: formatCurrency(bill['amount']),
                  onPayPressed: () => payBill(bill['amount'], bill['title']),
                );
              }).toList(),
            )
          : Center(
              child: Text(
                'TIDAK ADA TAGIHAN',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}

class BillItem extends StatelessWidget {
  final String title;
  final String amount;
  final VoidCallback onPayPressed;

  const BillItem({
    Key? key,
    required this.title,
    required this.amount,
    required this.onPayPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Total Amount: $amount',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onPayPressed,
            child: const Text('Bayar'),
          ),
        ],
      ),
    );
  }
}
