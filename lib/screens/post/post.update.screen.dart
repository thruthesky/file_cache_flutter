import 'package:philgo/globals.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PostUpdateScreen extends StatefulWidget {
  static const String routeName = '/post-update';

  // push 메서드 - 수정된 Post를 반환
  static Future<Post?> push(BuildContext ctx, {required Post post}) async {
    final result = await ctx.push(routeName, extra: {'post': post});
    return result as Post?;
  }

  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  final Post post;

  const PostUpdateScreen({super.key, required this.post});

  @override
  State<PostUpdateScreen> createState() => _PostUpdateScreenState();
}

class _PostUpdateScreenState extends State<PostUpdateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.post.subject;
    _contentController.text = widget.post.content;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(
          'Update: ${widget.post.subject}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.lightArrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: T.title,
                  hintText: T.postTitleHint,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return T.titleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: T.content,
                  hintText: T.postContentHint,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                minLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return T.contentRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  FileUpload(
                    file: true,
                    video: true,
                    child: const FaIcon(FontAwesomeIcons.lightCamera),
                    onUploaded: (url) {
                      debugLog('url: $url');
                    },
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.tertiaryContainer,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onTertiaryContainer,
                    ),
                    child: Text(T.cancel),
                  ),
                  SubmitButton(
                    isLoading: isLoading,
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        final updated = await philgoApiUpdatePost({
                          'idx': widget.post.idx,
                          'subject': _titleController.text,
                          'content': _contentController.text,
                        });

                        if (context.mounted) {
                          context.pop(updated);
                        }
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: Text(T.submit),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightInfo,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Writing Guide',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• Posts that defame others may be deleted'),
                    const SizedBox(height: 4),
                    const Text(
                      '• Advertisements and spam will be deleted immediately',
                    ),
                    const SizedBox(height: 4),
                    const Text('• Do not include personal information'),
                    const SizedBox(height: 4),
                    const Text(
                      '• Copyright infringing content cannot be posted',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
