import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _key = GlobalKey<FormState>(); final _name = TextEditingController(); final _email = TextEditingController(); final _password = TextEditingController();
  @override void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }
  Future<void> _submit() async { if (!(_key.currentState?.validate() ?? false)) return; final ok = await ref.read(authControllerProvider.notifier).register(name: _name.text.trim(), email: _email.text.trim(), password: _password.text); if (!mounted) return; if (ok) context.go('/home'); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kayıt başarısız.'))); }
  @override Widget build(BuildContext context) { final loading = ref.watch(authControllerProvider).isLoading; return Scaffold(appBar: AppBar(title: const Text('Kayıt Ol')), body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Form(key: _key, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const SizedBox(height: 20), Text('Yeni hesap oluştur', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 28), TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Ad soyad', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v == null || v.trim().length < 2 ? 'Ad soyad gerekli' : null), const SizedBox(height: 16), TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-posta', prefixIcon: Icon(Icons.email_outlined)), validator: (v) => v == null || !v.contains('@') ? 'Geçerli e-posta girin' : null), const SizedBox(height: 16), TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Şifre', prefixIcon: Icon(Icons.lock_outline)), validator: (v) => v == null || v.length < 6 ? 'En az 6 karakter olmalı' : null), const SizedBox(height: 28), SizedBox(height: 52, child: FilledButton(onPressed: loading ? null : _submit, child: loading ? const CircularProgressIndicator() : const Text('Kayıt Ol'))), const SizedBox(height: 12), TextButton(onPressed: () => context.go('/login'), child: const Text('Zaten hesabınız var mı? Giriş yapın'))]))); }
}
