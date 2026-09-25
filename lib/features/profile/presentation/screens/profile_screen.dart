import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/application/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) { final user = ref.watch(authControllerProvider).valueOrNull; return Scaffold(appBar: AppBar(title: const Text('Profil')), body: ListView(padding: const EdgeInsets.all(24), children: [Center(child: CircleAvatar(radius: 42, child: Text((user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 30)))), const SizedBox(height: 16), Center(child: Text(user?.name ?? 'Kullanıcı', style: Theme.of(context).textTheme.titleLarge)), Center(child: Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium)), const SizedBox(height: 32), Card(child: Column(children: [ListTile(leading: const Icon(Icons.person_outline), title: const Text('Ad soyad'), subtitle: Text(user?.name ?? '-')), const Divider(height: 1), ListTile(leading: const Icon(Icons.email_outlined), title: const Text('E-posta'), subtitle: Text(user?.email ?? '-'))])), const SizedBox(height: 24), OutlinedButton.icon(onPressed: () async { await ref.read(authControllerProvider.notifier).logout(); if (context.mounted) context.go('/login'); }, icon: const Icon(Icons.logout), label: const Text('Çıkış yap'))])); }
}
