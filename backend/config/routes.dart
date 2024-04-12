// Configure routes.
import 'package:shelf_router/shelf_router.dart';

import '../bin/server.dart';

final router = Router()
  ..get('/', rootHandler)
  ..get('/echo/<message>', echoHandler);
