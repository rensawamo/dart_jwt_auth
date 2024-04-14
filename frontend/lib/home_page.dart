import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final auth = ref.read(authProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('JWT Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              width: 200,
              height: 60,
              child: Center(
                child: Text(
                  authState.value != null
                      ? 'Current user is ${authState.value!.email}'
                      : "Yor aren't loged in.",
                ),
              ),
            ),
            if (authState.value == null)
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 200,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text(
                        '登録',
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 200,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text(
                        'ログイン',
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 200,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async => await auth.logout(),
                  child: const Text(
                    'ログアウト',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
