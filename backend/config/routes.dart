// Configure routes.
import 'package:shelf_router/shelf_router.dart';

import '../bin/server.dart';

final router = Router()
  ..get('/user', getUserHandler)
  ..post('/register', registerUserHandler)
  ..post('/login', loginHandler);
