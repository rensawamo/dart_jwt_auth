import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

// メールアドレスのテキストを保存するProvider
final emailProvider = StateProvider.autoDispose<TextEditingController>((ref) {
  return TextEditingController(text: '');
});

// パスワードのテキストを保存するProvider
final passwordProvider =
    StateProvider.autoDispose<TextEditingController>((ref) {
  return TextEditingController(text: '');
});

/// 認証のページ.
/// 今回は新規登録とログインは同じページにしました.
class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = ref.watch(emailProvider);
    final passwordController = ref.watch(passwordProvider);
    final auth = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // AndroidのAppBarの文字を中央寄せ.
        automaticallyImplyLeading: false, //戻るボタンを消す.
        title: const Text('ログイン'),
      ),
      body: authState.when(
        data: (_) =>
            _buildDataBody(emailController, passwordController, auth, context),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            _buildErrorBody(emailController, passwordController, auth, context),
      ),
    );
  }

  Widget _buildDataBody(
    TextEditingController emailController,
    TextEditingController passwordController,
    AuthNotifier auth,
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'パスワード'),
              obscureText: true,
            ),
            _buildElevatedButton('ログイン', () async {
              final email = emailController.text;
              final password = passwordController.text;
              final isLogin = await auth.login(email, password);
              if (isLogin) {
                Navigator.pop(context);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBody(
    TextEditingController emailController,
    TextEditingController passwordController,
    AuthNotifier auth,
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'パスワード'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            const Text(
              'メールアドレスまたはパスワードが違います。',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            _buildElevatedButton('ログイン', () async {
              final email = emailController.text;
              final password = passwordController.text;
              final isLogin = await auth.login(email, password);
              if (isLogin) {
                Navigator.pop(context);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildElevatedButton(String text, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      width: 200,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
