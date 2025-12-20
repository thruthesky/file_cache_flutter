import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

class PostViewYoutubes extends StatefulWidget {
  static const String routeName = '/PostViewYoutubes';

  const PostViewYoutubes({super.key, required this.post});

  final Post post;

  @override
  State<PostViewYoutubes> createState() => _PostViewYoutubesState();
}

class _PostViewYoutubesState extends State<PostViewYoutubes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PostViewYoutubes')),
      body: const Center(child: Text('Stateful Widget Template')),
    );
  }
}
