import 'package:test/test.dart';
import '../bin/jwt.dart';

void main() {
  test('JWT', () {
    const header = {'alg': 'HS256', 'typ': 'JWT'};
    const payload = {'sub': 'testtest', 'iat': 1516239022, 'exp': 1813150800};

    const key = 'secret';
    final jwt = generateJWT(header, payload, key);

    expect(checkJWT(key, jwt), true);

    if (checkJWT(key, jwt)) {
      final pl = getPayload(key, jwt);
      print(pl);
      expect(pl['sub'] == payload['sub'], true);
    }
  });

  test('invalid JWT', () {
    const header = {'alg': 'HS256', 'typ': 'JWT'};
    const payload = {'sub': 'testtest', 'iat': 1516239022, 'exp': 100};

    const key = 'secret';
    final jwt = generateJWT(header, payload, key);

    expect(checkJWT(key, jwt), false);
  });
}
