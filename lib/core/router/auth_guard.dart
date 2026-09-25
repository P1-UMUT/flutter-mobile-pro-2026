// lib/core/router/auth_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_provider.dart';
import '../../features/auth/domain/models/user_model.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final userState = ref.watch(authControllerProvider);
        final user = userState.value;

        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return child;
      },
    );
  }
}

final authGuardProvider = Provider<bool>((ref) {
  final user = ref.watch(authControllerProvider).value;
  return user != null;
});
