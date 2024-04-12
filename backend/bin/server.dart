import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import '../config/routes.dart';
import 'jwt.dart';

Response rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

// 新規登録
Future<Response> registerUserHandler(Request request) async {
  final query = await request.readAsString();
  final payload = jsonDecode(query) as Map<String, dynamic>;
  final newUser = User.fromJson(payload);
  final newUserId = generateRandomString();
  dummyDB[newUserId] = newUser;
  return Response.ok(
    convert.json.encode(
      {'id': newUserId, 'email': newUser.email},
    ),
  );
}

Future<Response> loginHandler(Request request) async {
  final headers = request.headers;
  final query = await request.readAsString();
  final payload = jsonDecode(query) as Map<String, dynamic>;
  final jwtToken = generateJWT(headers, payload, key);
  return Response.ok(convert.json.encode({'token': jwtToken}));
}

Response loginHandler(Request request) {
  return Response.ok('Hello, World!\n');
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('サーバー起動: http://${server.address.host}:${server.port}');
}
