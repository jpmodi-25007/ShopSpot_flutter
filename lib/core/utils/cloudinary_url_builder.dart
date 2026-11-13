import '../network/api_constants.dart';

class CloudinaryUrlBuilder {
  static const String _cloudinaryHost = 'res.cloudinary.com';

  /// Generates an optimized delivery URL when the source is Cloudinary.
  /// Absolute non-Cloudinary URLs (S3, CDN, backend uploads) are left intact.
  /// Relative paths are resolved against the API origin.
  static String buildUrl({
    required String secureUrl,
    int? width,
    int? height,
    String? cropMode,
    bool qAuto = true,
    bool fAuto = true,
  }) {
    var url = secureUrl.trim();
    if (url.isEmpty) return url;

    if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'https://');
    }

    // Relative backend paths: /uploads/... or uploads/...
    if (!url.startsWith('http')) {
      if (url.startsWith('/')) {
        final origin = Uri.parse(ApiConstants.baseUrl).origin;
        url = '$origin$url';
      } else if (url.contains('://') == false && !url.contains('/upload/')) {
        // Treat bare Cloudinary public IDs as Cloudinary assets.
        url = 'https://$_cloudinaryHost/image/upload/$url';
      } else if (url.startsWith('image/upload/') || url.startsWith('upload/')) {
        url = 'https://$_cloudinaryHost/${url.startsWith('image/') ? url : 'image/$url'}';
      }
    }

    final uri = Uri.tryParse(url);
    final isCloudinary =
        uri != null && uri.host.contains(_cloudinaryHost) && url.contains('/upload/');

    if (!isCloudinary) {
      return url;
    }

    final List<String> transformations = [];
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (cropMode != null) transformations.add('c_$cropMode');
    if (qAuto) transformations.add('q_auto');
    if (fAuto) transformations.add('f_auto');
    if (transformations.isEmpty) return url;

    final transformationStr = transformations.join(',');
    // Avoid stacking transforms if one is already present after /upload/.
    final alreadyTransformed = RegExp(r'/upload/(?:[^/]+,)?(?:w_|h_|c_|q_|f_)').hasMatch(url);
    if (alreadyTransformed) return url;
    return url.replaceFirst('/upload/', '/upload/$transformationStr/');
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
    return buildUrl(
      secureUrl: secureUrl,
      width: 250,
      height: 250,
      cropMode: 'fill',
    );
  }

  static bool isHttpUrl(String? value) {
    if (value == null) return false;
    final v = value.trim();
    if (v.isEmpty) return false;
    final uri = Uri.tryParse(v.startsWith('http') ? v : 'https://x/$v');
    return uri != null;
  }
}
