import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartinvoicemaker/invoicecreate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Invoice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void requestPermissions() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, you can proceed with your code.
    } else {
      // Permission denied, handle accordingly (show a message, ask again, etc.).
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InvoiceCreationPage(data: 1)));
                },
                child: const Text("Invoice 1")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InvoiceCreationPage(data: 2)));
            }, child: const Text("Invoice 2"))
          ],
        ),
      ),
    );
  }
}
