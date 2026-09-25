import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/application/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) { final user = ref.watch(authControllerProvider).valueOrNull; return Scaffold(appBar: AppBar(title: const Text('Kontrol Paneli'), actions: [IconButton(onPressed: () => context.push('/profile'), icon: const Icon(Icons.person_outline))]), body: ListView(padding: const EdgeInsets.all(20), children: [Text('Merhaba, ${user?.name ?? 'Kullanıcı'} 👋', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 8), const Text('Uygulamanızın genel durumuna buradan ulaşabilirsiniz.'), const SizedBox(height: 24), Row(children: [_metric(context, '12', 'Aktif kayıt', Icons.insights), const SizedBox(width: 12), _metric(context, '4', 'Bildirim', Icons.notifications_none)]), const SizedBox(height: 24), Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.rocket_launch)), title: const Text('Başlangıç tamamlandı'), subtitle: const Text('Auth, routing ve temel UI hazır.'), trailing: Icon(Icons.check_circle, color: Colors.green.shade600))), const SizedBox(height: 12), Card(child: ListTile(onTap: () => context.push('/profile'), leading: const Icon(Icons.manage_accounts_outlined), title: const Text('Profil ayarları'), subtitle: const Text('Hesap bilgilerinizi yönetin'), trailing: const Icon(Icons.chevron_right))) ])); }
  Widget _metric(BuildContext context, String value, String label, IconData icon) => Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 12), Text(value, style: Theme.of(context).textTheme.headlineMedium), Text(label)]))));
}
