class CloudinaryUrlBuilder {
  static const String _baseUrl = 'https://res.cloudinary.com/';

  /// Generates an optimized Cloudinary delivery URL
  /// By default uses automatic format and automatic quality.
  static String buildUrl({
    required String secureUrl,
    int? width,
    int? height,
    String? cropMode,
    bool qAuto = true,
    bool fAuto = true,
  }) {
    if (secureUrl.isEmpty || !secureUrl.contains('/upload/')) {
      return secureUrl;
    }

    final List<String> transformations = [];

    if (width != null) {
      transformations.add('w_$width');
    }
    
    if (height != null) {
      transformations.add('h_$height');
    }

    if (cropMode != null) {
      transformations.add('c_$cropMode');
    }

    if (qAuto) {
      transformations.add('q_auto');
    }

    if (fAuto) {
      transformations.add('f_auto');
    }

    if (transformations.isEmpty) {
      return secureUrl;
    }

    final String transformationStr = transformations.join(',');
    return secureUrl.replaceFirst('/upload/', '/upload/$transformationStr/');
  }

  /// Specifically for product listing thumbnails
  static String thumbnail(String secureUrl) {
    return buildUrl(secureUrl: secureUrl, width: 400, cropMode: 'fill');
  }

  /// Specifically for product detail full width
  static String detail(String secureUrl) {
    return buildUrl(secureUrl: secureUrl, width: 1000, cropMode: 'limit');
  }

  /// Profile image/avatar
  static String avatar(String secureUrl) {
    return buildUrl(secureUrl: secureUrl, width: 250, height: 250, cropMode: 'fill');
  }
}
