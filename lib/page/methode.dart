import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pembayaranonline/page/bayar.dart';
import 'dart:convert';

import 'package:pembayaranonline/page/HomePage.dart';

class PaymentMethod {
  final String group;
  final String code;
  final String name;
  final String type;
  final Map<String, dynamic> feeMerchant;
  final Map<String, dynamic> feeCustomer;
  final Map<String, dynamic> totalFee;
  final int? minimumFee;
  final int? maximumFee;
  late final String iconUrl;
  final bool active;

  PaymentMethod({
    required this.group,
    required this.code,
    required this.name,
    required this.type,
    required this.feeMerchant,
    required this.feeCustomer,
    required this.totalFee,
    this.minimumFee,
    this.maximumFee,
    required this.iconUrl,
    required this.active,
  });
}

class PaymentPage extends StatefulWidget {
  final String nisn;
  final int amount;
  final String title;

  PaymentPage({required this.nisn, required this.amount, required this.title});
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<PaymentMethod> paymentMethods = [];

  @override
  void initState() {
    super.initState();
    fetchPaymentMethods();
  }

  Future<void> fetchPaymentMethods() async {
    final response = await http
        .get(Uri.parse('https://tantri.jwnetradius.my.id/tripay/channel.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<PaymentMethod> paymentMethods = [];
      for (var item in data['data']) {
        PaymentMethod paymentMethod = PaymentMethod(
          group: item['group'],
          code: item['code'],
          name: item['name'],
          type: item['type'],
          feeMerchant: item['fee_merchant'],
          feeCustomer: item['fee_customer'],
          totalFee: item['total_fee'],
          minimumFee: item['minimum_fee'],
          maximumFee: item['maximum_fee'],
          iconUrl: item['icon_url'],
          active: item['active'],
        );
        paymentMethods.add(paymentMethod);
      }

      setState(() {
        this.paymentMethods = paymentMethods;
      });
    } else {
      throw Exception('Failed to fetch payment methods');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Metode Pembayaran'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: ListView.builder(
        itemCount: paymentMethods.length,
        itemBuilder: (context, index) {
          PaymentMethod paymentMethod = paymentMethods[index];
          return Card(
            child: ListTile(
              title: Text(paymentMethod.name),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BayarPage(
                        nisn: widget.nisn,
                        amount: widget.amount,
                        title: widget.title,
                        paymentMethodCode: paymentMethod.code,
                      ),
                    ),
                  );
                },
                child: Text('Pilih'),
              ),
            ),
          );
        },
      ),
    );
  }
}
