import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

String base64Encode(Map<String, dynamic> json) {
  final jsonStr = jsonEncode(json);
  final jsonB64 = base64Url.encode(Uint8List.fromList(utf8.encode(jsonStr)));
  final jsonB64NoPadding = jsonB64.replaceAll(RegExp(r'=+$'), '');
  return jsonB64NoPadding;
}

String base64Decode(String encodedString) {
  final paddedEncodedString = encodedString.padRight(
    (encodedString.length + 3) & ~3,
    '=',
  );
  final decodedBytes = base64Url.decode(paddedEncodedString);
  final decodedString = utf8.decode(decodedBytes);
  return decodedString;
}

String hmacSHA256(String key, String data) {
  final hmac = Hmac(sha256, utf8.encode(key));
  final hash = hmac.convert(utf8.encode(data));
  final hashNoPadding =
      base64Url.encode(hash.bytes).replaceAll(RegExp(r'=+$'), '');
  return hashNoPadding;
}

String generateJWT(
  Map<String, String>
      header, // Algorithm, Token type EX: {'alg': 'HS256', 'typ': 'JWT'};
  Map<String, dynamic>
      payload, // Data Ex: {'sub': '1234567890', 'iat': 1516239022};  (sub: user_id等のJWTの主語となる主体の識別子, iat: JWTの発行日時)
  String key, // 秘密鍵
) {
  // JSONをBase64エンコーディング
  final unsignedToken = '${base64Encode(header)}.${base64Encode(payload)}';

  // HMAC-SHA256より、JWTを生成
  final signature = hmacSHA256(key, unsignedToken);
  final jwt = '$unsignedToken.$signature';

  return jwt;
}

Map<String, dynamic> getPayload(String key, String jwt) {
  final splits = jwt.split('.');
  final payloadString = base64Decode(splits[1]);
  return convert.json.decode(payloadString) as Map<String, dynamic>;
}

bool isExpied(int timestamp) {
  return DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000))
          .inMilliseconds <
      0;
}

bool checkJWT(String key, String jwt) {
  final splits = jwt.split('.');
  final unsignedToken = '${splits[0]}.${splits[1]}'; // headers, payload
  final signature = splits[2];

  // 秘密鍵を用いて署名無しトークンが改竄されていないかチェック
  if (hmacSHA256(key, unsignedToken) != signature) return false;

  final payload = getPayload(key, jwt);

  // 有効期限チェック
  final diff = DateTime.now()
      .difference(
        DateTime.fromMillisecondsSinceEpoch((payload['exp'] as int) * 1000),
      )
      .inMicroseconds;
  if (diff > 0) return false;

  return true;
}
