import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool ipad = false;

  // GitHub RAW file URL
  final String fileUrl =
      "https://raw.githubusercontent.com/user/repo/main/file.txt";

  Future<void> downloadFile() async {

    await Permission.storage.request();

    final directory = await getExternalStorageDirectory();
    final raazFolder = Directory("${directory!.path}/Raaz");

    if (!raazFolder.existsSync()) {
      raazFolder.createSync(recursive: true);
    }

    final response = await http.get(Uri.parse(fileUrl));

    final file = File("${raazFolder.path}/ipad_file.txt");

    await file.writeAsBytes(response.bodyBytes);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File Downloaded in Raaz folder")),
      );
    }
  }

  Widget toggleCard(String title, bool value, Function(bool) onChanged) {

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.grey.shade900,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Gaming Tool UI"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView(
          children: [

            toggleCard("iPad View", ipad, (v) async {

              setState(() => ipad = v);

              if (v) {
                await downloadFile();
              }

            }),

          ],
        ),
      ),
    );
  }
}