import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import '../network/api_client.dart';

class CloudinaryUploadResult {
  final String publicId;
  final String secureUrl;
  final int width;
  final int height;
  final String format;
  final int bytes;
  final String resourceType;
  final String folder;

  CloudinaryUploadResult({
    required this.publicId,
    required this.secureUrl,
    required this.width,
    required this.height,
    required this.format,
    required this.bytes,
    required this.resourceType,
    required this.folder,
  });

  factory CloudinaryUploadResult.fromJson(Map<String, dynamic> json) {
    return CloudinaryUploadResult(
      publicId: json['public_id'],
      secureUrl: json['secure_url'],
      width: json['width'],
      height: json['height'],
      format: json['format'],
      bytes: json['bytes'],
      resourceType: json['resource_type'],
      folder: json['folder'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publicId': publicId,
      'secureUrl': secureUrl,
      'width': width,
      'height': height,
      'format': format,
      'bytes': bytes,
      'resourceType': resourceType,
      'folder': folder,
    };
  }
}

class CloudinaryService {
  final ApiClient _apiClient;

  CloudinaryService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Compresses an image file securely before upload
  Future<File?> _compressImage(File file) async {
    final filePath = file.absolute.path;
    
    // Create an output path for the compressed image
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp|.png|.webp|.jpeg'));
    if (lastIndex == -1) return file; // Unsupported format for compression, return original
    
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_compressed.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      minWidth: 2000,
      minHeight: 2000,
      quality: 85,
    );
    
    if (result != null) {
      return File(result.path);
    }
    return file; // Fallback to original
  }

  /// Complete flow: compress -> sign -> upload to Cloudinary -> return result
  Future<CloudinaryUploadResult> uploadImage({
    required File imageFile,
    required String folder,
    void Function(double)? onProgress,
  }) async {
    try {
      // 1. Compress image
      final compressedFile = await _compressImage(imageFile);
      final fileToUpload = compressedFile ?? imageFile;

      // 2. Request Signature from Backend
      final signatureResponse = await _apiClient.post(
        '/cloudinary/signature',
        data: {'folder': folder},
      );
      
      final Map<String, dynamic> data = signatureResponse.data['data'];
      final String signature = data['signature'];
      final int timestamp = data['timestamp'];
      final String apiKey = data['apiKey'];
      final String cloudName = data['cloudName'];
      final String finalFolder = data['folder'];

      // 3. Upload directly to Cloudinary via HTTP Multipart Request
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['api_key'] = apiKey;
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;
      request.fields['folder'] = finalFolder;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          fileToUpload.path,
        ),
      );

      // We'd ideally use a streamed request with progress, but http.MultipartRequest doesn't natively support byte-level upload progress well. 
      // For a more advanced progress bar, Dio is better, but http works perfectly for direct uploads.
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return CloudinaryUploadResult.fromJson(jsonResponse);
      } else {
        debugPrint('Cloudinary Upload Failed: \${response.body}');
        throw Exception('Failed to upload image to Cloudinary');
      }
    } catch (e) {
      debugPrint('CloudinaryService Error: $e');
      rethrow;
    }
  }
}
