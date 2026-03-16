import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/user/user.ready.dart';

import '../app.config.dart';
import '../user/user.model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: UserReady(
        yes: (context, user) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                _buildLevelCard(user),
                const SizedBox(height: 16),
                _buildInfoCard(user),
                const SizedBox(height: 16),
                _buildPostViewButton(context),
                const SizedBox(height: 16),
                _buildAppConfigCard(),
              ],
            ),
          );
        },
        no: (p0) => Center(
          child: Text('로그인 후 이용할 수 있습니다.'.tr(), style: text.bodyMedium),
        ),
      ),
    );
  }

  /// 프로필 헤더: 사진 + 이름
  Widget _buildProfileHeader(UserModel user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: Colors.grey[200],
          backgroundImage: user.photoUrl.isNotEmpty
              ? NetworkImage(user.photoUrl)
              : null,
          child: user.photoUrl.isEmpty
              ? Icon(Icons.person, size: 48, color: Colors.grey[400])
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          user.displayName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (user.id.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              user.id,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }

  /// 레벨 카드: 레벨 + 포인트 + 진행률 바
  Widget _buildLevelCard(UserModel user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lv. ${user.level}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  '${user.point}P',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: user.levelProgress / 100,
                minHeight: 10,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '다음 레벨까지 {}%'.tr(args: ['${user.levelProgress}']),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 정보 카드: 전화번호, 게시글, 댓글
  Widget _buildInfoCard(UserModel user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          if (user.phoneNumber.isNotEmpty)
            _infoTile(Icons.phone, '전화번호'.tr(), user.phoneNumber),
          _infoTile(
            Icons.article_outlined,
            '게시글'.tr(),
            '{}개'.tr(args: ['${user.noOfPost}']),
          ),
          _infoTile(
            Icons.comment_outlined,
            '댓글'.tr(),
            '{}개'.tr(args: ['${user.noOfComment}']),
          ),
          if (user.gender.isNotEmpty)
            _infoTile(
              Icons.person_outline,
              '성별'.tr(),
              user.gender == 'M' ? '남성'.tr() : '여성'.tr(),
            ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// 앱 설정 카드: API 엔드포인트, 베이스 URL, 포럼 카테고리 수
  Widget _buildAppConfigCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '앱 설정'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _configRow('API 엔드포인트'.tr(), v7ApiEndpoint),
            _configRow('베이스 URL'.tr(), v7BaseUrl),
            _configRow(
              '포럼 카테고리'.tr(),
              '{}개'.tr(args: ['${forumCategories.length}']),
            ),
            _configRow(
              '카카오 앱 키'.tr(),
              '${kakaoNativeAppKey.substring(0, 8)}...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _configRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  /// 게시글 보기 버튼
  Widget _buildPostViewButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.push('/post/view?idx=1275710403&post_id=qna');
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        '게시글 보기'.tr(),
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
