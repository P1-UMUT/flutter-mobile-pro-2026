import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await ref.read(authControllerProvider.notifier).login(email: _email.text.trim(), password: _password.text);
    if (!mounted) return;
    if (ok) context.go('/home'); else _message('Giriş başarısız. Bilgilerinizi kontrol edin.');
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider).isLoading;
    return Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Icon(Icons.shield_outlined, size: 76, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 20),
      Text('Tekrar hoş geldiniz', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
      const SizedBox(height: 8), const Text('Hesabınıza güvenli şekilde giriş yapın', textAlign: TextAlign.center), const SizedBox(height: 32),
      TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-posta', prefixIcon: Icon(Icons.email_outlined)), validator: (v) => v == null || !v.contains('@') ? 'Geçerli bir e-posta girin' : null),
      const SizedBox(height: 16),
      TextFormField(controller: _password, obscureText: _obscure, decoration: InputDecoration(labelText: 'Şifre', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off))), validator: (v) => v == null || v.length < 6 ? 'Şifre en az 6 karakter olmalı' : null),
      const SizedBox(height: 24), SizedBox(height: 52, child: FilledButton(onPressed: loading ? null : _submit, child: loading ? const CircularProgressIndicator() : const Text('Giriş Yap'))),
      const SizedBox(height: 12), TextButton(onPressed: () => context.go('/register'), child: const Text('Hesabınız yok mu? Kayıt olun')),
    ]))))));
  }
}
