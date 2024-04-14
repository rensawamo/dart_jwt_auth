import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

// メールアドレスのテキストを保存するProvider
final emailProvider = StateProvider.autoDispose((ref) {
  return TextEditingController(text: '');
});

final passwordProvider = StateProvider.autoDispose((ref) {
  // パスワードのテキストを保存するProvider
  return TextEditingController(text: '');
});

/// 認証のページ.
/// 今回は新規登録とログインは同じページにしました.
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

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
          data: (_) => Center(
                child: Container(
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
                      ElevatedButton(
                        child: const Text('ログイン'),
                        onPressed: () async {
                          final email = emailController.text;
                          final password = passwordController.text;
                          auth.login(email, password);
                          // try {
                          //   // メール/パスワードでログイン
                          //   final User? user = (await FirebaseAuth.instance
                          //           .signInWithEmailAndPassword(
                          //               email: emailController.text,
                          //               password: passwordlController.text))
                          //       .user;
                          //   if (user != null) context.go('/mypage');
                          // } catch (e) {
                          //   print(e);
                          // }
                        },
                      ),
                    ],
                  ),
                ),
              ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Container()),
    );
  }
}
