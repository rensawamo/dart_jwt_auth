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
class SignUpPage extends ConsumerWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = ref.watch(emailProvider);
    final passwordlController = ref.watch(passwordProvider);
    final auth = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // AndroidのAppBarの文字を中央寄せ.
        automaticallyImplyLeading: false, //戻るボタンを消す.
        title: const Text('新規登録'),
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
                  controller: passwordlController,
                  decoration: const InputDecoration(labelText: 'パスワード'),
                  obscureText: true,
                ),
                ElevatedButton(
                  child: const Text('ユーザ登録'),
                  onPressed: () async {
                    final email = emailController.text;
                    final password = passwordlController.text;
                    await auth.register(email, password);
                    Navigator.pop(context);
                    // try {
                    //   final User? user = (await FirebaseAuth.instance
                    //           .createUserWithEmailAndPassword(
                    //               email: emailController.text,
                    //               password: passwordlController.text))
                    //       .user;
                    //   if (user != null) {}
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
        error: (e, _) => Container(),
      ),
    );
  }
}
