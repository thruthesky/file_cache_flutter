import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';

/// 홈 개발 모드 배너 - API 연결 상태 + 유저 정보 표시
///
/// 디버그 모드에서만 표시되며, 현재 연결된 API 엔드포인트와 로그인 유저를 보여준다.
/// 프로덕션 API에 연결되어 있으면 빨간색 경고를 강하게 표시한다.
class HomeDevModeBanner extends StatefulWidget {
  const HomeDevModeBanner({super.key});

  @override
  State<HomeDevModeBanner> createState() => _HomeDevModeBannerState();
}

class _HomeDevModeBannerState extends State<HomeDevModeBanner> {
  static const _env = String.fromEnvironment('ENV');

  bool _dismissed = false;

  bool get _isProduction {
    final uri = Uri.tryParse(v7ApiEndpoint);
    final host = uri?.host ?? '';
    // Only exact 'philgo.com' is production, not subdomains like v7-local.philgo.com
    final isProductionHost = host == 'philgo.com' || host == 'www.philgo.com';
    return isProductionHost || (_env != 'dev' && _env.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || _dismissed) return const SizedBox.shrink();

    final isProd = _isProduction;
    final userState = context.watch<UserState>();
    final user = userState.user;
    final textColor = isProd ? Colors.red.shade700 : Colors.green.shade700;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isProd ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isProd ? Colors.red : Colors.green,
          width: isProd ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isProd) ...[
                Icon(Icons.warning_amber_rounded,
                    size: 16, color: Colors.red.shade700),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'PRODUCTION MODE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ] else
                const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _dismissed = true),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: textColor,
                ),
              ),
            ],
          ),
          if (isProd) const SizedBox(height: 2),
          Text(
            'API: $v7ApiEndpoint',
            style: TextStyle(
              fontSize: 10,
              fontWeight: isProd ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'ENV: ${_env.isEmpty ? "(not set)" : _env}',
            style: TextStyle(fontSize: 10, color: textColor),
          ),
          const Divider(height: 8, thickness: 0.5),
          if (user != null) ...[
            _info('idx', '${user.idx}', textColor),
            _info('id', user.id, textColor),
            _info('name', user.name, textColor),
            _info('nickname', user.nickname, textColor),
            _info('phone', user.phoneNumber, textColor),
            _info('firebase', user.firebaseUid, textColor),
            _info('gender', user.gender, textColor),
            _info('level', '${user.level} (${user.levelProgress}%)', textColor),
            _info('point', '${user.point}', textColor),
            _info('posts', '${user.noOfPost}', textColor),
            _info('comments', '${user.noOfComment}', textColor),
          ] else
            Text(
              'User: Not logged in',
              style: TextStyle(fontSize: 10, color: textColor),
            ),
        ],
      ),
    );
  }

  Widget _info(String label, String value, Color textColor) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 10, color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
