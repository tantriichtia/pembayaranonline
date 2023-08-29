import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatPage extends StatefulWidget {
  @override
  _RiwayatPageState createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<Map<String, dynamic>> paymentHistory = [];
  List<Map<String, dynamic>> filteredPaymentHistory = [];
  late String nisn; // Menyimpan nilai NISN dari shared preferences
  TextEditingController searchController = TextEditingController();

  Future<List<Map<String, dynamic>>> fetchPaymentHistory() async {
    final response = await http.get(Uri.parse(
        'https://tantri.jwnetradius.my.id/API/pembayaran.php?nisn=$nisn')); // Menggunakan nilai NISN dalam URL
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to fetch payment history');
    }
  }

  @override
  void initState() {
    super.initState();
    getNISNFromSharedPreferences().then((value) {
      setState(() {
        nisn = value;
      });
      fetchPaymentHistory().then((data) {
        setState(() {
          paymentHistory = data;
          filteredPaymentHistory = data;
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

  String formatCurrency(int amount) {
    var formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return formatter.format(amount);
  }

  void filterPaymentHistory(String query) {
    setState(() {
      filteredPaymentHistory = paymentHistory
          .where((payment) =>
              payment['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  String formatDate(DateTime date) {
    var formatter = DateFormat('dd MMMM yyyy');
    return formatter.format(date);
  }

  String getStatusText(int status) {
    return status == 0 ? 'Belum Lunas' : 'Lunas';
  }

  Color getStatusColor(int status) {
    return status == 0 ? Colors.red : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembayaran'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterPaymentHistory,
              decoration: InputDecoration(
                labelText: 'Cari',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredPaymentHistory.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredPaymentHistory.length,
                    itemBuilder: (context, index) {
                      final historyItem = filteredPaymentHistory[index];
                      final paymentDate = DateTime.parse(historyItem['date']);
                      return PaymentHistoryCard(
                        title: historyItem['title'],
                        amount: formatCurrency(historyItem['amount']),
                        date: formatDate(paymentDate),
                        status: historyItem['status'],
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'TIDAK ADA RIWAYAT PEMBAYARAN',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class PaymentHistoryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final int status;

  const PaymentHistoryCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
  }) : super(key: key);

  String getStatusText(int status) {
    return status == 0 ? 'Belum Lunas' : 'Lunas';
  }

  Color getStatusColor(int status) {
    return status == 0 ? Colors.red : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Amount: $amount',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Date: $date',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Status: ${getStatusText(status)}',
              style: TextStyle(
                fontSize: 16,
                color: getStatusColor(status),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
