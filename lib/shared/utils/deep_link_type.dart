enum DeepLinkType {
  business,
  news,
  share,
  promos,
  businessDetails,
  unknown,
}

class DeepLinkInfo {
  final DeepLinkType type;
  final String? id;
  final String path;
  final String host;
  final String scheme;
  final Uri rawUri;
  final Map<String, String> allParams;

  const DeepLinkInfo({
    required this.type,
    required this.id,
    required this.path,
    required this.host,
    required this.scheme,
    required this.rawUri,
    required this.allParams,
  });
}

class DeepLinkUtils {
  static const String baseHost = "meetclic.com";

  static const String businessPrefix = "/business";
  static const String newsPrefix = "/news";
  static const String sharePrefix = "/share";
  static const String promosPrefix = "/promos";
  static const String businessDetailsPrefix = "/es/businessDetails";

  static DeepLinkInfo fromUri(Uri uri) {
    final path = uri.path;
    final host = uri.host;
    final scheme = uri.scheme;

    DeepLinkType type = DeepLinkType.unknown;
    String? id;

    if (path.startsWith(businessDetailsPrefix)) {
      type = DeepLinkType.businessDetails;
      id = _extractLastSegment(path);
    } else if (path.startsWith(businessPrefix)) {
      type = DeepLinkType.business;
      id = _extractLastSegment(path);
    } else if (path.startsWith(newsPrefix)) {
      type = DeepLinkType.news;
      id = _extractLastSegment(path);
    } else if (path.startsWith(sharePrefix)) {
      type = DeepLinkType.share;
      id = _extractLastSegment(path);
    } else if (path.startsWith(promosPrefix)) {
      type = DeepLinkType.promos;
      id = _extractLastSegment(path);
    }

    final allParams = <String, String>{
      if (id != null) 'id': id,
      ...uri.queryParameters,
    };

    return DeepLinkInfo(
      type: type,
      id: id,
      path: path,
      host: host,
      scheme: scheme,
      rawUri: uri,
      allParams: allParams,
    );
  }

  static String _extractLastSegment(String path) {
    final segments = path.split('/');
    return segments.where((e) => e.isNotEmpty).last;
  }

  static String typeToString(DeepLinkType type) {
    switch (type) {
      case DeepLinkType.business:
        return "business";
      case DeepLinkType.news:
        return "news";
      case DeepLinkType.share:
        return "share";
      case DeepLinkType.promos:
        return "promos";
      case DeepLinkType.businessDetails:
        return "businessDetails";
      default:
        return "unknown";
    }
  }
}
