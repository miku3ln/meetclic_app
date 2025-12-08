import 'package:flutter/cupertino.dart';

import '../../../../../infrastructure/deep_links/deep_link_handler.dart';
import '../../../../../shared/utils/deep_link_type.dart';

class HomeDeepLinkService {
  final DeepLinkHandler _handler;

  HomeDeepLinkService(this._handler);

  Stream<Uri> get uriLinkStream => _handler.uriLinkStream;

  Future<Uri?> getInitialLink() => _handler.getInitialLink();

  DeepLinkInfo? parse(Uri uri, BuildContext context) {
    return _handler.parseUri(uri, context);
  }
}
