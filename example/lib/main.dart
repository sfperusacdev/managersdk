import 'package:flutter/material.dart';
import 'package:managersdk/licence.dart';
import 'package:managersdk/managersdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  List<Licence> licences = [];
  String deviceName = "";
  String deviceID = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () async {
                final notifier = ScaffoldMessenger.of(context);
                try {
                  deviceID = await ManagerSDKF().deviceID();
                  deviceName = await ManagerSDKF().deviceName();
                  final result = await ManagerSDKF().readLicences();
                  setState(() => licences = result);
                } catch (err) {
                  var snackBar = SnackBar(content: Text(err.toString()));
                  notifier.showSnackBar(snackBar);
                }
              },
              child: const Text("Leer data"),
            ),
            const SizedBox(height: 20.0),
            Text(
              deviceID,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            Text(
              deviceName,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            ...licences.map(
              (e) => ListTile(
                title: Text(e.company ?? ""),
                subtitle: Text(e.licenceCode ?? ""),
              ),
            )
          ],
        ),
      ),
    );
  }
}
