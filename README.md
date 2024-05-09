
### [参照](https://qiita.com/Odatetsu/items/2326575f01a9a460ace4#%E3%83%98%E3%83%83%E3%83%80%E3%83%BC-header)

### [認証パターン 論文](https://iopscience.iop.org/article/10.1088/1742-6596/910/1/012060/pdf)

## JWTと JWS 
JWSとはJSON Web Signatureの略で、ヘッダーとペイロードと署名のJSON形式のデータをそれぞれBase64URLでエンコードして.で連結した文字列

![alt text](assets/jwt.png)

JWS = ヘッダー ＋  ペイロード ＋  署名

###  ヘッダー
```sh
{
  "alg": "HS256",  # ハッシュアルゴリズム
  "typ": "JWT"     # トークンのタイプ
}
```

###  ペイロード
```sh
{
  "sub": "1234567890",       # ユーザ識別子。user_idといったユーザを識別するためのID
  "exp": 1234567890,         # JWTの有効期限
  "iss": "hoge_service",     # JWTの発行者
  "iat": 1234567890,         # JWTの発行日時
  "email": "test@kmail.com", # プライベートクレーム original
}
```

上記以外

- aud  :   JWTの受信者

- nbf  :   有効開始日時

- jti  :   JWTのID


### 署名
ヘッダーとペイロードを連結し、秘密鍵(secret)を使ってHMAC等のハッシュアルゴリズムで署名したもの。もしHeaderかPayloadのデータが改竄されていれば、JWT検証時に署名を用いて復号ができなくなるため、改竄を検知することができる。



###  サービス間での JWT 

-  認証サーバによって 秘密鍵を用いて 認証用のトークンが発行されて、その他は、公開鍵で解読して、上記ペイロードの情報をよみとり
サーバーが異なるマイクロサービスでも ユーザの識別とトークンの情報を共有できる


![alt text](assets/micro.png)


## サーバ側 Dart の  主要関数


###  新規ユーザの登録
userid と passwordを dbに保存
```sh
Future<Response> registerUserHandler(Request request) async {
```

##  ログイン
リクエストから email と passwordの認証をおこなう
そして、認証が通ったら JWTを返す

```sh
Future<Response> loginHandler(Request request) async {
```


### jwtを作成する関数
引数は以下  (引数に渡すとき 使用するアルゴリズムとか 有効期限とかをきめる)

-  ヘッダー :  hash アルゴリズムと type

- payload   :  // Data Ex: {'sub': '1234567890', 'iat': 1516239022};  (sub: user_id等のJWTの主語となる主体の識別子, iat: JWTの発行日時)
  
- key       :  秘密鍵

ハッシュ暗号化をつかい秘密鍵でJWTを作成


```sh
String generateJWT(
```



###  ペイロードを使って 特定のユーザー情報を取得する関数
Get で headerに Autentization情報を取得。その時点で JWT tokenがないとエラーをだす。

そして、JWT tokenのなかの ペイロードを取得して user_idを取り出す。
その情報をもとに、自身のdbに問い合わせ情報と status ok をresponseとして返す


```sh
Future<Response> getUserHandler(Request request) async {
```



##  フロント側 Dart の主要関数

### 新規登録
サーバDartのdbに mail と passを追加する

```sh
  FutureOr<bool> register(String email, String password) async {
```

### ログイン
サーバーから 正常response がかえってきたら、
secure storageに JWT token を保存する


###  ユーザ情報取得

ヘッダーに JWT tokenを含めることで、ユーザー情報をサーバー側が ペイロードを読み取り識別し
結果をレスポンスしてくれる。
このように、マイクロサービスにおいて複数サーバーがあるときに有効。



![image](https://github.com/rensawamo/dart_jwt_auth/assets/106803080/521b1094-ec73-404e-b6ca-514d2df42ba3)







