// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pembayaranonline/page/HomePage.dart';
// import 'package:pembayaranonline/page/konfirmasi.dart';

class BayarPage extends StatefulWidget {
  final String nisn;
  final String title;
  final int amount;
  final String paymentMethodCode;

  BayarPage(
      {required this.nisn,
      required this.amount,
      required this.title,
      required this.paymentMethodCode});
  @override
  _BayarPageState createState() => _BayarPageState();
}

class _BayarPageState extends State<BayarPage> {
  Map<String, dynamic>? responseData;
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final Uri url = Uri.parse(
        'https://tantri.jwnetradius.my.id/tripay/bayar.php?nisn=${widget.nisn}&amount=${widget.amount}&paymentMethodCode=${widget.paymentMethodCode}&title=${widget.title}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        responseData = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }

  void konfirmasiPembayaran() async {
    if (responseData != null) {
      final url = Uri.parse(
          'https://tantri.jwnetradius.my.id/tripay/trx.php?trx=${responseData!['data']['reference']}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'PAID') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Pembayaran Berhasil'),
                content: Text('Pembayaran Anda telah berhasil dikonfirmasi.'),
                actions: [
                  TextButton(
                    child: Text('Tutup'),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pembayaran gagal dikonfirmasi')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Terjadi kesalahan dalam mengkonfirmasi pembayaran')),
        );
      }
    }
  }

  String expired(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);

    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Pembayaran'),
      ),
      body: responseData == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metode Pembayaran',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${responseData!['data']['payment_name']}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Kode Pembayaran',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        title: Text(
                          '${responseData!['data']['pay_code']}',
                        ),
                        trailing: Icon(Icons.content_copy),
                        onTap: () {
                          Clipboard.setData(ClipboardData(
                              text: responseData!['data']['pay_code']));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Kode berhasil disalin')),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Total Dibayar:',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      currencyFormat.format(responseData!['data']['amount']),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Berlaku sampai :',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      expired(responseData!['data']['expired_time']),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Langkah - Langkah :',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: responseData!['data']['instructions'].length,
                      itemBuilder: (context, index) {
                        var instruction =
                            responseData!['data']['instructions'][index];
                        var steps =
                            instruction['steps'].cast<String>().map((step) {
                          return step
                              .replaceAll('<b>', '')
                              .replaceAll('</b>', '');
                        }).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${instruction['title']}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: steps.length,
                              itemBuilder: (context, index) {
                                return RichText(
                                  text: TextSpan(
                                    text: '- ',
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .copyWith(fontSize: 14),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: steps[index],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: konfirmasiPembayaran,
                      child: Text('Konfirmasi Pembayaran'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
