import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../user/user.model.dart';
import '../user/user.state.dart';

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
      body: Consumer<UserState>(
        builder: (context, userState, _) {
          if (userState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userState.isLoggedIn) {
            return const Center(
              child: Text(
                '로그인이 필요합니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          final user = userState.user!;
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
              ],
            ),
          );
        },
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
          backgroundImage:
              user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
          child:
              user.photoUrl.isEmpty
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
                '다음 레벨까지 ${user.levelProgress}%',
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
            _infoTile(Icons.phone, '전화번호', user.phoneNumber),
          _infoTile(Icons.article_outlined, '게시글', '${user.noOfPost}개'),
          _infoTile(Icons.comment_outlined, '댓글', '${user.noOfComment}개'),
          if (user.gender.isNotEmpty)
            _infoTile(
              Icons.person_outline,
              '성별',
              user.gender == 'M' ? '남성' : '여성',
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
}
