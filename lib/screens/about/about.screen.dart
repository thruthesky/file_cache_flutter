import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/screens/home/home.screen.dart';

class AboutScreen extends StatefulWidget {
  static const String routeName = '/about';
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.of(context).pop()
              : context.go(HomeScreen.routeName),
        ),
        title: const Text('About'),
      ),
      body: const Center(child: Text('Welcome to about Screen')),
    );
  }
}
