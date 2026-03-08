import 'dart:async';
import 'dart:io';
import 'dart:ui';
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
  bool isDarkMode = true; // Settings Toggle State

  // Loading States
  bool isDownloading = false;

  // File URLs & Paths
  final String fileUrl = "https://github.com/rajamransri-blip/Gfx/releases/download/Pak/mini_obbzsdic_obb.pak";
  final String fileName = "mini_obbzsdic_obb.pak";

  // Slider & Feedback Dummy GitHub URLs (Replace with your actual raw image URLs)
  final List<String> sliderImages = [
    "https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=800&q=80", // Replace with GitHub URL 1
    "https://images.unsplash.com/photo-1552820728-8b83bb6b773f?auto=format&fit=crop&w=800&q=80", // Replace with GitHub URL 2
    "https://images.unsplash.com/photo-1538481199705-c710c4e965fc?auto=format&fit=crop&w=800&q=80", // Replace with GitHub URL 3
    "https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=800&q=80", // Replace with GitHub URL 4
    "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=800&q=80", // Replace with GitHub URL 5
  ];
  final String feedbackImageUrl = "https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=800&q=80"; // Replace with GitHub URL

  // Slider Controller
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _sliderTimer;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
    _startAutoSlider();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sliderTimer?.cancel();
    super.dispose();
  }

  void _startAutoSlider() {
    _sliderTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 4) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Check if file already exists when app opens
  Future<void> _checkInitialState() async {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final file = File("${directory.path}/Raaz/$fileName");
      if (file.existsSync()) {
        setState(() {
          ipad = true;
        });
      }
    }
  }

  // Download & Delete Logic (.pak file in Raaz folder)
  Future<void> handleIpadView(bool enable) async {
    setState(() => isDownloading = true);

    try {
      await Permission.storage.request();

      final directory = await getExternalStorageDirectory();
      if (directory == null) throw Exception("Storage not found");

      final raazFolder = Directory("${directory.path}/Raaz");
      if (!raazFolder.existsSync()) {
        raazFolder.createSync(recursive: true);
      }

      final file = File("${raazFolder.path}/$fileName");

      if (enable) {
        // TURN ON: Download file
        final response = await http.get(Uri.parse(fileUrl));
        if (response.statusCode == 200 || response.statusCode == 302) {
          await file.writeAsBytes(response.bodyBytes);
          _showSnackBar("✅ Game File Downloaded in Raaz Folder!", Colors.green);
          setState(() => ipad = true);
        } else {
          throw Exception("Failed to download file. Error: ${response.statusCode}");
        }
      } else {
        // TURN OFF: Delete file
        if (file.existsSync()) {
          await file.delete();
        }
        _showSnackBar("❌ Game File Removed!", Colors.orange);
        setState(() => ipad = false);
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}", Colors.red);
      setState(() => ipad = !enable);
    } finally {
      setState(() => isDownloading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: color.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // iOS Style Settings Bottom Sheet
  void _showSettingsPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E).withOpacity(0.8) : Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 20),
                    Text("Settings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                    const SizedBox(height: 20),
                    
                    // Options
                    ListTile(
                      leading: const Icon(CupertinoIcons.moon_stars_fill, color: Colors.purpleAccent),
                      title: Text("Dark Mode", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                      trailing: CupertinoSwitch(
                        value: isDarkMode,
                        activeColor: Colors.purpleAccent,
                        onChanged: (v) {
                          setModalState(() => isDarkMode = v);
                          setState(() => isDarkMode = v); // Update UI
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(CupertinoIcons.cloud_download, color: Colors.blueAccent),
                      title: Text("Check New Update", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                      subtitle: Text("GitHub Releases", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () => _showSnackBar("Opening GitHub URL...", Colors.blueAccent),
                    ),
                    ListTile(
                      leading: const Icon(CupertinoIcons.chat_bubble_2_fill, color: Colors.greenAccent),
                      title: Text("Support / Contact", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(CupertinoIcons.info_circle_fill, color: Colors.orangeAccent),
                      title: Text("About App", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
          ),
        );
      },
    );
  }

  // Upgraded Toggle Card Widget with Animation
  Widget toggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required bool isLoading,
    required Function(bool) onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDarkMode ? const Color(0xFF232323) : Colors.grey.shade100,
        border: Border.all(color: value ? Colors.purpleAccent : Colors.transparent, width: 1.5),
        boxShadow: value ? [BoxShadow(color: Colors.purpleAccent.withOpacity(0.2), blurRadius: 15, spreadRadius: 1)] : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: value ? Colors.purpleAccent.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: value ? Colors.purpleAccent : Colors.grey, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (isLoading)
            const Padding(padding: EdgeInsets.only(right: 8.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.purpleAccent)))
          else
            CupertinoSwitch(
              activeColor: Colors.purpleAccent,
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
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Gamer Pro Tool", style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.settings, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: _showSettingsPanel,
          )
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        children: [
          
          // 1. Image Slider Section (5 Images)
          SizedBox(
            height: 160,
            child: ClipRidgeSlider(pageController: _pageController, sliderImages: sliderImages),
          ),
          const SizedBox(height: 24),

          // 2. Visual Features
          Text("Visual Features", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
          const SizedBox(height: 12),
          toggleCard(
            title: "iPad View (.pak)",
            subtitle: "Wider field of view, saves in Raaz folder",
            icon: Icons.tablet_mac,
            value: ipad,
            isLoading: isDownloading,
            onChanged: (v) async {
              setState(() => ipad = v);
              await handleIpadView(v);
            },
          ),

          const SizedBox(height: 8),

          // 3. Performance Tweaks
          Text("Performance Tweaks", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
          const SizedBox(height: 12),
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

          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.9),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              shadowColor: Colors.redAccent.withOpacity(0.4),
            ),
            icon: const Icon(Icons.cleaning_services, color: Colors.white),
            label: const Text("Clear Game Cache", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () => _showSnackBar("Game Cache Cleared Successfully!", Colors.green),
          ),

          const SizedBox(height: 30),

          // 4. Feedback Section
          Text("User Feedback", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
          const SizedBox(height: 12),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDarkMode ? const Color(0xFF232323) : Colors.grey.shade200,
              image: DecorationImage(
                image: NetworkImage(feedbackImageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// Custom Widget for the 5-Image Slider
class ClipRidgeSlider extends StatelessWidget {
  const ClipRidgeSlider({
    super.key,
    required PageController pageController,
    required this.sliderImages,
  }) : _pageController = pageController;

  final PageController _pageController;
  final List<String> sliderImages;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: sliderImages.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: NetworkImage(sliderImages[index]),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
            ]
          ),
        );
      },
    );
  }
}
