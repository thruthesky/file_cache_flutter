import 'dart:developer';

import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

List<String?> getEnvironmentalPostId(String? postId, String? category) {
  if (Config.isDevelopment) {
    if (category == null || category.isEmpty) {
      return ['temp', ''];
    } else {
      return ['temp', category];
    }
  }
  return [postId, category];
}

String? getEnvironmentalCategory(String? category) {
  return category;
}

Future<PostList> getPosts({
  String? postId,
  String? category,
  bool has_image = false,
  int page = 1,
  int limit = 20,
}) async {
  [postId, category] = getEnvironmentalPostId(postId, category);
  final res = await func(
    'post_list',
    data: {
      if (postId != null) 'post_id': postId,
      if (category != null) 'category': category,
      if (has_image) 'has_image': 'y',
      'page': page,
      'limit': limit,
    },
    debug: true,
  );
  // debugLog('getPosts: $res');
  return PostList.fromJson(res);
}

Future<Post> getPost(int id) async {
  final res = await func('post.view', data: {'idx': id});
  // debugLog('getPost: $res');

  final post = Post.fromJson(res);

  log('=== GET POST API RESPONSE ===');
  log('$post');
  log('============================');

  return post;
}

Future<List<Post>> getLatestByUser(String uid, {int limit = 10}) async {
  final res = await func<List<dynamic>>(
    'post.latest-by-user',
    data: {'uid': uid, 'limit': limit},
  );
  debugLog('getPosts: $res');
  return (res).map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
}

Future<Post> createPost({
  required String postId,
  String? category,
  String? subject,
  String? content,
}) async {
  // Testing purposes
  final ret = getEnvironmentalPostId(postId, category);
  postId = ret[0]!;
  category = ret[1];
  category = getEnvironmentalCategory(category);
  final res = await func(
    'create_post_func',
    data: {
      'post_id': postId,
      if (category != null) 'category': category,
      if (subject != null) 'subject': subject,
      if (content != null) 'content': content,
    },
  );
  debugLog('createPost: $res');
  return Post.fromJson(res);
}
