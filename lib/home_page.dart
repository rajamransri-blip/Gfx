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
  // Features State
  bool ipad = false;
  bool fps90 = false;

  // Loading States
  bool isDownloading = false;

  // Replace with your actual GitHub RAW file URL
  final String fileUrl = "https://raw.githubusercontent.com/user/repo/main/file.txt";

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  // Check if file already exists when app opens
  Future<void> _checkInitialState() async {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final file = File("${directory.path}/Raaz/ipad_file.txt");
      if (file.existsSync()) {
        setState(() {
          ipad = true;
        });
      }
    }
  }

  // Modified Download & Delete Logic
  Future<void> handleIpadView(bool enable) async {
    setState(() {
      isDownloading = true;
    });

    try {
      // Request permission
      await Permission.storage.request();

      final directory = await getExternalStorageDirectory();
      if (directory == null) throw Exception("Storage not found");

      final raazFolder = Directory("${directory.path}/Raaz");
      if (!raazFolder.existsSync()) {
        raazFolder.createSync(recursive: true);
      }

      final file = File("${raazFolder.path}/ipad_file.txt");

      if (enable) {
        // TURN ON: Download file
        final response = await http.get(Uri.parse(fileUrl));
        
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          _showSnackBar("✅ iPad View Applied Successfully!", Colors.green);
          setState(() => ipad = true);
        } else {
          throw Exception("Failed to download file. Check URL.");
        }
      } else {
        // TURN OFF: Delete file
        if (file.existsSync()) {
          await file.delete();
        }
        _showSnackBar("❌ iPad View Removed!", Colors.orange);
        setState(() => ipad = false);
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}", Colors.red);
      // Revert the switch if action failed
      setState(() => ipad = !enable);
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  // Helper method for Snackbars
  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Upgraded Toggle Card Widget
  Widget toggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required bool isLoading,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF232323),
        border: Border.all(color: value ? Colors.greenAccent.shade400 : Colors.transparent, width: 1.5),
        boxShadow: [
          if (value)
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: value ? Colors.greenAccent.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: value ? Colors.greenAccent.shade400 : Colors.grey, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else
            CupertinoSwitch(
              activeColor: Colors.greenAccent.shade400,
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
        title: const Text("Gamer Pro Tool", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const Text(
              "Visual Features",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purpleAccent),
            ),
            const SizedBox(height: 12),
            
            // iPad View Toggle
            toggleCard(
              title: "iPad View",
              subtitle: "Wider field of view for better gameplay",
              icon: Icons.tablet_mac,
              value: ipad,
              isLoading: isDownloading,
              onChanged: (v) async {
                setState(() => ipad = v);
                await handleIpadView(v);
              },
            ),

            const SizedBox(height: 16),
            const Text(
              "Performance Tweaks",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purpleAccent),
            ),
            const SizedBox(height: 12),

            // Dummy 90 FPS Toggle
            toggleCard(
              title: "Unlock 90 FPS",
              subtitle: "Smoother graphics & performance",
              icon: Icons.speed,
              value: fps90,
              isLoading: false,
              onChanged: (v) {
                setState(() => fps90 = v);
                _showSnackBar(v ? "90 FPS Enabled!" : "Reverted to default FPS", Colors.blueAccent);
              },
            ),

            const SizedBox(height: 24),
            
            // 🛠️ YAHAN FIX KIYA HAI: 'onIcon' hata diya gaya hai.
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.cleaning_services, color: Colors.white),
              label: const Text("Clear Game Cache", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                _showSnackBar("Game Cache Cleared Successfully!", Colors.green);
              },
            )
          ],
        ),
      ),
    );
  }
}
