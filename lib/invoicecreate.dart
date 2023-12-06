import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartinvoicemaker/pdfviewer.dart';
import 'package:sqflite/sqflite.dart';

import 'DatabaseHelper.dart';
import 'item.dart';
import 'itemlist.dart';

class InvoiceCreationPage extends StatefulWidget {
  final int data;

  // Constructor to receive data
  InvoiceCreationPage({required this.data});

  @override
  _InvoiceCreationPageState createState() => _InvoiceCreationPageState();
}

class _InvoiceCreationPageState extends State<InvoiceCreationPage> {
  late String selectedCurrency;
  String selectedValue = 'US Dollar'; // Default value for the spinner
  List<String> currencyOptions = [
    'US Dollar',
    'Indian Rupee',
    'Canadian Dollar'
  ];

  late String imagePath;
  TextEditingController invoiceNoController = TextEditingController();
  late String invoiceNo = '1';
  TextEditingController invoiceFromController = TextEditingController();
  late String invoiceFrom = 'XYZ';
  TextEditingController billToController = TextEditingController();
  late String billTo = 'XYZ';
  TextEditingController shipToController = TextEditingController();
  late String shipTo = 'XYZ';
  TextEditingController paymentTermsController = TextEditingController();
  late String paymentTerms = 'XYZ';
  TextEditingController poNumerController = TextEditingController();
  late String poNumer = '123';
  TextEditingController balanceDueController = TextEditingController();
  late String balanceDue = '00';
  TextEditingController subtotalController = TextEditingController();
  late String subtotal = '00';
  TextEditingController discountController = TextEditingController();
  late String discount = '00';
  TextEditingController taxController = TextEditingController();
  late String tax = '00';
  TextEditingController shippingController = TextEditingController();
  late String shipping = '00';
  TextEditingController totalController = TextEditingController();
  late String total = '00';
  TextEditingController amountPaidController = TextEditingController();
  late String amountPaid = '00';
  TextEditingController notesController = TextEditingController();
  late String notes = 'xyz';
  TextEditingController termsController = TextEditingController();
  late String terms = 'xyz';
  DateTime selectedInvoiceDate = DateTime.now();
  DateTime selectedDueDate = DateTime.now();
  List<Item> itemList = [];
  late String _pdfPath;
  late double subTotal = 0.0;
  late double discounts = 0.0;
  late double taxTotal = 0.0;
  late double totalAmount = 0.0;
  late double paidAmount = 0.0;
  late double balanceDues = 0.0;

  @override
  void initState() {
    super.initState();
    selectedCurrency = 'US Dollar';
    loadImagePathFromPreferences();
    loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Creation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _generatePdf();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: imagePath.isNotEmpty
                                ? FileImage(File(
                                    imagePath)) // Cast to ImageProvider<Object>
                                : const AssetImage(
                                        'assets/images/default_image.png')
                                    as ImageProvider<
                                        Object>, // Cast to ImageProvider<Object>
                          ),
                          const Text(
                            'Add Image',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            decoration: customTextFieldDecoration('#1', '#1'),
                            controller: invoiceNoController,
                            onChanged: (text) {
                              setState(() {
                                invoiceNo = text;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
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
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.text,
                decoration:
                    customTextFieldDecoration('Payment Terms', 'Payment Terms'),
                controller: paymentTermsController,
                onChanged: (text) {
                  setState(() {
                    paymentTerms = text;
                  });
                },
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectInvoiceDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(
                            text: selectedInvoiceDate
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                          ),
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                          decoration:
                              customTextFieldDecoration('Invoice Date', ''),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDueDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(
                            text: selectedDueDate
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                          ),
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                          decoration: customTextFieldDecoration('Due Date', ''),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: customTextFieldDecoration('PO Number', 'PO Number'),
                controller: poNumerController,
                onChanged: (text) {
                  setState(() {
                    poNumer = text;
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Other Information',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.text,
                decoration: customTextFieldDecoration(
                    'Who is this invoice from?(required)',
                    'Who is this invoice from?(required)'),
                controller: invoiceFromController,
                onChanged: (text) {
                  setState(() {
                    invoiceFrom = text;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.text,
                decoration: customTextFieldDecoration(
                    'Who is this invoice to?(required)',
                    'Who is this invoice to?(required)'),
                controller: billToController,
                onChanged: (text) {
                  setState(() {
                    billTo = text;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.text,
                decoration: customTextFieldDecoration(
                    'Ship to (Optional)', 'Ship to (Optional)'),
                controller: shipToController,
                onChanged: (text) {
                  setState(() {
                    shipTo = text;
                  });
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showAddItemDialog(context),
                      child: const Center(
                        child: Text(
                          'Add Item',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.blue, // Adjust color as needed
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ItemListScreen()),
                        );
                      },
                      child: const Text('Go to Item List'),
                    ),
                  ),
                ],
              ),
              Text('                                                      * ${items.length} Item Added Already',
                style: const TextStyle(fontSize: 12.0, color: Colors.grey, decoration: TextDecoration.none,),
                textAlign: TextAlign.right,),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration:
                          customTextFieldDecoration(shipping, 'shipping'),
                      controller: shippingController,
                      onChanged: (text) {
                        setState(() {
                          shipping = text;
                          refreshData();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration:
                          customTextFieldDecoration(amountPaid, 'amountPaid'),
                      controller: amountPaidController,
                      onChanged: (text) {
                        setState(() {
                          amountPaid = text;
                          refreshData();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: customTextFieldDecoration('Tax %', 'Tax'),
                      controller: taxController,
                      onChanged: (text) {
                        setState(() {
                          tax = text;
                          refreshData();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration:
                          customTextFieldDecoration('Discount %', 'Discount'),
                      controller: discountController,
                      onChanged: (text) {
                        setState(() {
                          discount = text;
                          refreshData();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: Text(
                        'Balance Due',
                        style: TextStyle(fontSize: 16.0),
                      )),
                  SizedBox(height: 15),
                  Expanded(
                      child: Text(
                        'Total',
                        style: TextStyle(fontSize: 16.0),
                      ),),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      '$balanceDues',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  )),
                  const SizedBox(height: 15),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      '$totalAmount',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.text,
                decoration: customTextFieldDecoration('Notes:', 'Notes'),
                controller: notesController,
                onChanged: (text) {
                  setState(() {
                    notes = text;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.text,
                decoration:
                    customTextFieldDecoration('Terms & Condition', 'Terms'),
                controller: termsController,
                onChanged: (text) {
                  setState(() {
                    terms = text;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration customTextFieldDecoration(String hintText, String labelText) {
    return InputDecoration(
      labelText: labelText,
      // hintText: hintText,
      labelStyle: const TextStyle(color: Colors.black, fontSize: 16.0),
      contentPadding: const EdgeInsets.all(15.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
    );
  }

  Future<void> saveSelectedValue(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('CURRENCY', value);
  }

  Future<void> loadImagePathFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      imagePath = prefs.getString('imagePath') ?? '';
      print("Picked Image Path: $imagePath");
    });
  }

  Future<void> saveImagePathToPreferences(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('imagePath', path);
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print("Picked Image Path: ${pickedFile.path}");
      setState(() {
        imagePath = pickedFile.path;
      });
      await saveImagePathToPreferences(imagePath);
    }
  }

  Future<void> _selectInvoiceDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedInvoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedInvoiceDate) {
      setState(() {
        selectedInvoiceDate = pickedDate;
      });
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDueDate) {
      setState(() {
        selectedDueDate = pickedDate;
      });
    }
  }

  List<Map<String, dynamic>> items = [];

  Future<void> loadItems() async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> itemList = await db.query('items');

    setState(() {
      items = itemList;
    });

    for (var index = 0; index < items.length; index++) {
      subTotal = items[index]['total'] + subTotal;
    }

    print(">> $subTotal");
    refreshData();
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    String itemName = '';
    String itemQuantity = '';
    String itemPrice = '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SizedBox(
            child: AlertDialog(
              title: const Text('Add Item'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // Item Name TextField
                    TextField(
                      onChanged: (value) {
                        itemName = value;
                      },
                      decoration: const InputDecoration(labelText: 'Item Name'),
                    ),
                    const SizedBox(height: 10),

                    // Item Quantity TextField
                    TextField(
                      onChanged: (value) {
                        itemQuantity = value;
                      },
                      decoration:
                          const InputDecoration(labelText: 'Item Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),

                    // Item Price TextField
                    TextField(
                      onChanged: (value) {
                        itemPrice = value;
                      },
                      decoration:
                          const InputDecoration(labelText: 'Item Price'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                // Done Button
                ElevatedButton(
                  onPressed: () async {
                    if (itemName.isNotEmpty &&
                        itemQuantity.isNotEmpty &&
                        itemPrice.isNotEmpty) {
                      Item newItem = Item(
                          name: itemName,
                          quantity: int.parse(itemQuantity),
                          price: double.parse(itemPrice));

                      setState(() {
                        itemList.add(newItem);
                      });
                      Database db = await DatabaseHelper.instance.database;

                      try {
                        await db.insert('items', newItem.toMap());
                      } catch (e) {
                        print('Error inserting item: $e');
                      }

                      print("items: ${itemList.length}");
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Done'),
                ),

                // Close Button
                ElevatedButton(
                  onPressed: () {
                    // Handle the close button action
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _generatePdf() async {
    loadItems();
    final pdf = pw.Document();
    pw.TextStyle textStyle1 = pw.TextStyle(
      fontSize: 12,
      color: PdfColor.fromHex('#000000'),
    );
    pw.TextStyle textStyle2 = pw.TextStyle(
      fontSize: 12,
      color: PdfColor.fromHex('#808080'),
    );
    pw.TextStyle textStyle3 = pw.TextStyle(
      fontSize: 12,
      color: PdfColor.fromHex('#FFFFFF'),
    );
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Stack(
          children: [
            // Image in the top left corner with specified width and height
            pw.Positioned(
              left: 0,
              top: 0,
              child: pw.Image(
                pw.MemoryImage(File(imagePath).readAsBytesSync()),
                width: 80, // Set the desired width
                height: 80, // Set the desired height
              ),
            ),

            // Column for text below image
            pw.Positioned(
              left: 0,
              top: 90,
              // Adjust the top position based on your image height
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    invoiceFrom,
                    style: textStyle1,
                  ),
                  // Add more text elements as needed
                ],
              ),
            ),

            // Text "INVOICE" in the exact right top corner
            pw.Positioned(
              right: 0,
              top: 30,
              child: pw.Text(
                'INVOICE',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 30),
              ),
            ),

            // Column for text below "INVOICE"
            pw.Positioned(
              right: 0,
              top: 70,
              // Adjust the top position based on your "INVOICE" text size
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '#$invoiceNo',
                    style: textStyle1,
                  ),
                  // Add more text elements as needed
                ],
              ),
            ),

            // Table of 4 items
            pw.Positioned(
                left: 0,
                top: 120,
                // Adjust the top position based on your text below "INVOICE"
                child: pw.Center(
                  child: pw.Container(
                      width: 480, // Set a sufficiently large width
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          children: [
                            pw.Table(
                              // border: pw.TableBorder.all(width: 1.0, color: PdfColor.fromHex('#000000')),
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child:
                                          pw.Text('Bill To', style: textStyle2),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child:
                                          pw.Text('Ship To', style: textStyle2),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('Date:',
                                          style: textStyle2,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text(
                                          selectedInvoiceDate
                                              .toLocal()
                                              .toString()
                                              .split(' ')[0],
                                          style: textStyle1,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text(billTo, style: textStyle1),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text(shipTo, style: textStyle1),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('Payment Terms:',
                                          style: textStyle2,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text(paymentTerms,
                                          style: textStyle1,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle1),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle1),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('Due Date:',
                                          style: textStyle2,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text(
                                          selectedDueDate
                                              .toLocal()
                                              .toString()
                                              .split(' ')[0],
                                          style: textStyle1,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle1),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle1),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('PO Number:',
                                          style: textStyle2,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text(' $poNumer',
                                          style: textStyle1,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle1),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle1),
                                    ),
                                    pw.Container(
                                      color: PdfColor.fromHex('#d5d5d5'),
                                      padding: const pw.EdgeInsets.all(8.0),
                                      // Add padding here
                                      child: pw.Text('Balance Due:',
                                          style: textStyle1,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                    pw.Container(
                                      color: PdfColor.fromHex('#d5d5d5'),
                                      padding: const pw.EdgeInsets.all(8.0),
                                      // Add padding here
                                      child: pw.Text(' $balanceDue',
                                          style: textStyle1,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 10.0),
                            pw.Table(
                              children: [
                                pw.TableRow(
                                  decoration: pw.BoxDecoration(
                                      color: PdfColor.fromHex('#373737')),
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('No.',
                                          style: textStyle3,
                                          textAlign: pw.TextAlign.left),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('Item',
                                          style: textStyle3,
                                          textAlign: pw.TextAlign.left),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('Quantity',
                                          style: textStyle3,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('Rate',
                                          style: textStyle3,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('Total',
                                          style: textStyle3,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                  ],
                                ),
                                for (var index = 0;
                                    index < items.length;
                                    index++)
                                  pw.TableRow(
                                    children: [
                                      pw.Container(
                                        padding: const pw.EdgeInsets.all(8.0),
                                        child: pw.Text('${index + 1}',
                                            style: textStyle1),
                                      ),
                                      pw.Container(
                                        padding: const pw.EdgeInsets.all(8.0),
                                        child: pw.Text(
                                            items[index]['name'].toString(),
                                            style: textStyle1),
                                      ),
                                      pw.Container(
                                        padding: const pw.EdgeInsets.all(8.0),
                                        child: pw.Text(
                                            items[index]['quantity'].toString(),
                                            style: textStyle1,
                                            textAlign: pw.TextAlign.right),
                                      ),
                                      pw.Container(
                                        padding: const pw.EdgeInsets.all(8.0),
                                        child: pw.Text(
                                            items[index]['price'].toString(),
                                            style: textStyle1,
                                            textAlign: pw.TextAlign.right),
                                      ),
                                      pw.Container(
                                        padding: const pw.EdgeInsets.all(8.0),
                                        child: pw.Text(
                                            (items[index]['quantity'] *
                                                    items[index]['price'])
                                                .toString(),
                                            style: textStyle1,
                                            textAlign: pw.TextAlign.right),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            pw.SizedBox(height: 10.0),
                            pw.Table(
                              // border: pw.TableBorder.all(
                              //     width: 1.0,
                              //     color: PdfColor.fromHex('#000000')),
                              columnWidths: {
                                0: const pw.FixedColumnWidth(50),
                                1: const pw.FixedColumnWidth(50),
                                2: const pw.FixedColumnWidth(80),
                                3: const pw.FixedColumnWidth(80),
                              },
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle2),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle2),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('Subtotal:',
                                          style: textStyle2,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('$subTotal',
                                          style: textStyle1,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle2),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle2),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('Discount',
                                          style: textStyle2,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('$discounts',
                                          style: textStyle1,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle2),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle2),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('Tax',
                                          style: textStyle2,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('$taxTotal',
                                          style: textStyle1,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle2),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle2),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('Shipping:',
                                          style: textStyle2,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text(shipping,
                                          style: textStyle1,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle2),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle2),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('Total: ',
                                          style: textStyle2,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('$totalAmount',
                                          style: textStyle1,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle2),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('', style: textStyle2),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('Amount Paid: ',
                                          style: textStyle2,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(8.0),
                                      child: pw.Text('$paidAmount',
                                          style: textStyle1,
                                          textAlign: pw.TextAlign.right),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            pw.Table(
                              // border: pw.TableBorder.all(
                              //     width: 1.0,
                              //     color: PdfColor.fromHex('#000000')),
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(5.0),
                                      child: pw.Text('Notes:',
                                          style: textStyle2,
                                          textAlign: pw.TextAlign.left),
                                    )
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(5.0),
                                      child: pw.Text(notes,
                                          style: textStyle1,
                                          textAlign: pw.TextAlign.left),
                                    )
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(5.0),
                                      child: pw.Text('Terms:',
                                          style: textStyle2,
                                          textAlign: pw.TextAlign.left),
                                    )
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(5.0),
                                      child: pw.Text(terms,
                                          style: textStyle1,
                                          textAlign: pw.TextAlign.left),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ])),
                )),
          ],
        ),
      ),
    );

    // Get the documents directory
    final externalDirectory = await getExternalStorageDirectory();

    final pdfsDirectory = Directory('${externalDirectory!.path}/MyInvoice');
    if (!pdfsDirectory.existsSync()) {
      pdfsDirectory.createSync();
    }

    // Generate a unique file name (e.g., based on the current timestamp)
    final DateTime now = DateTime.now();
    final String fileName = 'invoice_${now.millisecondsSinceEpoch}.pdf';
    // const String fileName = 'invoice.pdf';

    // Save the PDF to the MyInvoice directory
    final File file = File('${externalDirectory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    setState(() {
      _pdfPath = file.path;
    });
    print("path $_pdfPath");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(pdfPath: _pdfPath),
      ),
    );
  }

  void refreshData() {
    print("subTotal $subTotal");
    print("tax $tax");
    print("discount $discount");
    print("amountPaid $amountPaid");

    if (double.tryParse(discount) != 0) {
      discounts = ((double.parse(discount) * subTotal) / 100.0);
    } else {
      discounts = 0;
    }
    print("discounts $discounts");

    double totalAmount1 = (subTotal - discounts);

    print("discountss $totalAmount1");

    if (double.tryParse(tax) != 0) {
      taxTotal = ((double.parse(tax) * totalAmount1) / 100.0);
    } else {
      taxTotal = 0;
    }

    print("taxTotal $taxTotal");

    totalAmount = totalAmount1 + taxTotal + double.parse(shipping);

    print("totalAmount $totalAmount");

    paidAmount = double.parse(amountPaid);
    balanceDues = (totalAmount - paidAmount);
    balanceDue = '$balanceDues';
  }
}
