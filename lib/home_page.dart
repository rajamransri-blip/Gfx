import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool aimbot = false;
  bool ipadView = false;
  bool smooth = false;
  bool fps90 = false;

  Widget toggleCard(String title, bool value, Function(bool) onChanged) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: value
              ? [Colors.greenAccent, Colors.green]
              : [Colors.grey.shade900, Colors.black],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
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

            toggleCard("Aimbot", aimbot, (v){
              setState(() => aimbot = v);
            }),

            toggleCard("iPad View", ipadView, (v){
              setState(() => ipadView = v);
            }),

            toggleCard("Smooth Graphics", smooth, (v){
              setState(() => smooth = v);
            }),

            toggleCard("90 FPS Mode", fps90, (v){
              setState(() => fps90 = v);
            }),

          ],
        ),
      ),
    );
  }
}