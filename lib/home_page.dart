import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool ipad = false;
  bool smooth = false;
  bool fps = false;

  Widget toggleCard(String title, bool value, Function(bool) onChanged) {

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: value ? Colors.green : Colors.grey.shade900,
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

            toggleCard("iPad View", ipad, (v){
              setState(() => ipad = v);
            }),

            toggleCard("Smooth Graphics", smooth, (v){
              setState(() => smooth = v);
            }),

            toggleCard("90 FPS Mode", fps, (v){
              setState(() => fps = v);
            }),

          ],
        ),
      ),
    );
  }
}