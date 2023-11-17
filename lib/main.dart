import 'package:absensi/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(home: AbsensiApp()));
}

class AbsensiApp extends StatefulWidget {
  const AbsensiApp({super.key});

  @override
  _AbsensiAppState createState() => _AbsensiAppState();
}

class _AbsensiAppState extends State<AbsensiApp> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  String _currentPosition = '';

  @override
  void dispose() {
    namaController.dispose();
    super.dispose();
  }

  _getCurrentLocation() async {
  PermissionStatus permission = await Permission.location.status;

  if (permission != PermissionStatus.granted) {
    permission = await Permission.location.request();
    if (permission != PermissionStatus.granted) {
      // Handle permission denial
      return;
    }
  }
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  setState(() {
    _currentPosition = '${position.latitude}, ${position.longitude}';
  });
}

  @override
  Widget build(BuildContext context) {
    CollectionReference absensi = FirebaseFirestore.instance.collection('absensi');

    return Scaffold(
      appBar: AppBar(title: const Text('Aplikasi Absensi Karyawan')),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Karyawan'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan Nama Karyawan';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  absensi.add({
                    'nama': namaController.text,
                    'waktu': DateTime.now(),
                    'lokasi': _currentPosition
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data absensi berhasil disimpan')));
                }
              },
              child: const Text('Submit'),
            ),
            ElevatedButton(
              onPressed: () {
                _getCurrentLocation();
              },
              child: const Text('Dapatkan Lokasi'),
            ),
          ],
        ),
      ),
    );
  }
}
