import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import '../config/routes.dart';
import '../util/generate_random_string.dart';
import 'jwt.dart';

const key = 'secret_key';

final dummyDB = <String, Map<String, String>>{}; // email: password, user_id

Future<Response> getUserHandler(Request request) async {
  final query = await request.readAsString();
  final payload = jsonDecode(query) as Map<String, dynamic>;
  final jwt = payload['token'] as String;
  if (!checkJWT(key, jwt)) {
    return Response.forbidden(
      convert.json.encode({'message': 'token is expired.'}),
    );
  }
  final jwtPayload = getPayload(key, jwt);
  final userId = jwtPayload['user_id'] as String;
  final email = dummyDB.keys.firstWhere(
    (k) => dummyDB[k]!['user_id'] == userId,
  );
  return Response.ok(convert.json.encode({'user_id': userId, 'email': email}));
}

// 新規登録
Future<Response> registerUserHandler(Request request) async {
  final query = await request.readAsString();
  final payload = jsonDecode(query) as Map<String, dynamic>;
  final newUserId = generateRandomString();
  dummyDB[payload['email'] as String] = {
    'password': payload['password'] as String,
    'user_id': newUserId,
  };
  return Response.ok(
    convert.json.encode(
      {'id': newUserId, 'email': payload['email']},
    ),
  );
}

Future<Response> loginHandler(Request request) async {
  final headers = request.headers;
  final query = await request.readAsString();
  final payload = jsonDecode(query) as Map<String, dynamic>;

  if (!dummyDB.containsKey(payload['email'])) {
    return Response.unauthorized(
      convert.json.encode({'message': 'email is not found.'}),
    );
  }

  if (dummyDB[payload['email']]!['password'] != payload['password']) {
    return Response.unauthorized(
      convert.json.encode({'message': 'password is wrong.'}),
    );
  }

  // 有効期限は1分間
  final jwtPayload = {
    'user_id': dummyDB[payload['email']]!['user_id'],
    'iat': (DateTime.now().millisecondsSinceEpoch / 1000).round(),
    'exp': ((DateTime.now().millisecondsSinceEpoch) / 1000 + 60).round(),
  };

  final jwtToken = generateJWT(headers, jwtPayload, key);
  return Response.ok(convert.json.encode({'token': jwtToken}));
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('サーバー起動: http://${server.address.host}:${server.port}');
}
