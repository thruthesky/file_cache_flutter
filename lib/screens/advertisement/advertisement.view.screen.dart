import 'package:flutter/material.dart';

class AdvertisementViewScreen extends StatefulWidget {
  final int idx;
  const AdvertisementViewScreen({super.key, required this.idx});

  @override
  State<AdvertisementViewScreen> createState() =>
      _AdvertisementViewScreenState();
}

class _AdvertisementViewScreenState extends State<AdvertisementViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AdvertisementView')),
      body: const Column(children: [Text("AdvertisementView")]),
    );
  }
}
