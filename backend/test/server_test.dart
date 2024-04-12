import 'package:test/test.dart';
import '../bin/jwt.dart';

void main() {
  test('JWT', () {
    const header = {'alg': 'HS256', 'typ': 'JWT'};
    const payload = {'sub': 'testtest', 'iat': 1516239022, 'exp': 151624000};

    const key = 'secret';
    final jwt = generateJWT(header, payload, key);

    expect(checkJWT(key, jwt), true);

    if (checkJWT(key, jwt)) {
      final pl = getPayload(key, jwt);
      print(pl);
      expect(pl['sub'] == payload['sub'], true);
    }
  });
}
