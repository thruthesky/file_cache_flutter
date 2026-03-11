import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../user.state.dart';

class UserLoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    final userState = context.read<UserState>();
    final success = await userState.signInWithGoogle();
    if (!mounted) return;
    if (success) {
      context.pop();
    } else if (userState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userState.error!)),
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.lightChevronLeft, size: 18, color: scheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // 로고 & 타이틀
              Column(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightCircleUser,
                    size: 72,
                    color: scheme.primary,
                  ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 20),
                  Text(
                    '필고에 오신 것을 환영합니다',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 8),
                  Text(
                    '소셜 계정으로 간편하게 로그인하세요',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
                ],
              ),

              const Spacer(),

              // Google 로그인 버튼
              _GoogleSignInButton(
                loading: _loading,
                onTap: _signInWithGoogle,
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _GoogleSignInButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          border: Border.all(color: scheme.outlineVariant, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: loading
            ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.google, size: 20, color: scheme.onSurface),
                  const SizedBox(width: 12),
                  Text(
                    'Google로 로그인',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
