import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:dio/dio.dart';
import '../network/api_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LegalDocumentBottomSheet extends StatefulWidget {
  final String role;
  final String documentType; // 'terms' or 'privacy'

  const LegalDocumentBottomSheet({
    super.key,
    required this.role,
    required this.documentType,
  });

  static void show(BuildContext context, {required String role, required String documentType}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LegalDocumentBottomSheet(role: role, documentType: documentType),
    );
  }

  @override
  State<LegalDocumentBottomSheet> createState() => _LegalDocumentBottomSheetState();
}

class _LegalDocumentBottomSheetState extends State<LegalDocumentBottomSheet> {
  bool _isLoading = true;
  String _content = '';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchDocument();
  }

  Future<void> _fetchDocument() async {
    try {
      final dio = Dio();
      final response = await dio.get('${ApiConstants.baseUrl}/auth/legal/${widget.role}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (mounted) {
          setState(() {
            _content = data[widget.documentType] ?? 'Content not available.';
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load document');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load document. Please check your internet connection.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.documentType == 'terms' ? 'Terms of Service' : 'Privacy Policy';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.neutral200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTextStyles.h3),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Text(_error, style: TextStyle(color: Colors.red)))
                    : Markdown(
                        data: _content,
                        styleSheet: MarkdownStyleSheet(
                          h1: AppTextStyles.h2,
                          h2: AppTextStyles.h3,
                          p: AppTextStyles.body,
                          listBullet: AppTextStyles.body,
                        ),
                      ),
          ),
          
          // Footer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.primary500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
