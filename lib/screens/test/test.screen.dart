import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TestScreen extends StatefulWidget {
  // You may add routeName with dynamic parameters if needed like this:
  // static const String routeName = '/screen-name/:id';
  // And update the push and go methods accordingly like below.
  // static Function(BuildContext ctx, String _) go = (ctx, roomId) => ctx.go(routeName.replaceFirst(':id', roomId));
  static const String routeName = '/test';
  static Function(BuildContext ctx, String _) push = (ctx, roomId) =>
      ctx.push(routeName);
  static Function(BuildContext ctx, String _) go = (ctx, roomId) =>
      ctx.go(routeName);
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test')),
      body: const Column(children: [Text("Test")]),
    );
  }
}
