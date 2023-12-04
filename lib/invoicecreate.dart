import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceCreationPage extends StatefulWidget {
  final int data;

  // Constructor to receive data
  InvoiceCreationPage({required this.data});

  @override
  _InvoiceCreationPageState createState() => _InvoiceCreationPageState();
}

class _InvoiceCreationPageState extends State<InvoiceCreationPage>{
  String selectedValue = 'US Dollar'; // Default value for the spinner
  List<String> currencyOptions = ['US Dollar', 'Indian Rupee', 'Canadian Dollar'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Creation'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // Add save functionality here
              // You can access widget.data to get the data passed from the previous screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10,left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            DropdownButton<String>(
              value: selectedValue,
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue!;
                  saveSelectedValue(selectedValue);
                });
              },
              items: currencyOptions
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      )
    );
  }

  Future<void> saveSelectedValue(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('CURRENCY', value);
  }

}