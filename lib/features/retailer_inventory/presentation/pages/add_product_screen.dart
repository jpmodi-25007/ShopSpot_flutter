import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validation_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/network/api_client.dart';
import '../bloc/retailer_inventory_bloc.dart';
import '../../../product/domain/entities/product_entity.dart';

class AddProductScreen extends StatefulWidget {
  final ProductEntity? product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _categoryController = TextEditingController();
  final _mrpController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();
  
  bool _trackInventory = true;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isUploading = false;
  final CloudinaryService _cloudinary = getIt<CloudinaryService>();
  List<String> _existingImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameController.text = p.name;
      _brandController.text = p.brand ?? '';
      _categoryController.text = p.categoryId ?? '';
      _mrpController.text = p.mrp.toString();
      _priceController.text = p.sellingPrice.toString();
      _stockController.text = p.stockQuantity.toString();
      _descController.text = p.description ?? '';
      _existingImages = List.from(p.images);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _mrpController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final currentTotal = _existingImages.length + _selectedImages.length;
    if (currentTotal >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 5 images allowed.')));
      return;
    }
    final List<XFile> picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(picked);
        if (_existingImages.length + _selectedImages.length > 5) {
           final allowedNew = 5 - _existingImages.length;
           _selectedImages = _selectedImages.sublist(0, allowedNew);
        }
      });
    }
  }

  Future<void> _publishProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Check selling price <= mrp
    final mrp = double.tryParse(_mrpController.text);
    final sp = double.tryParse(_priceController.text);
    if (mrp != null && sp != null && sp > mrp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selling Price cannot be greater than MRP'), backgroundColor: AppColors.error500),
      );
      return;
    }

    if (_selectedImages.isEmpty && _existingImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one product image.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final List<CloudinaryUploadResult> uploadResults = [];
      
      // Upload sequentially for stability (can be parallelized)
      for (var img in _selectedImages) {
        final result = await _cloudinary.uploadImage(
          imageFile: img,
          folder: 'products/temp',
        );
        uploadResults.add(result);
      }

      final existingMedia = _existingImages.map((url) => {
        'publicId': 'existing',
        'secureUrl': url,
      }).toList();

      final newMedia = uploadResults.map((r) => {
        'publicId': r.publicId,
        'secureUrl': r.secureUrl,
        'width': r.width,
        'height': r.height,
        'format': r.format,
        'bytes': r.bytes,
        'resourceType': r.resourceType,
      }).toList();

      final payload = {
        'name': _nameController.text,
        'brand': _brandController.text.isNotEmpty ? _brandController.text : null,
        'mrp': mrp ?? 0,
        'sellingPrice': sp ?? 0,
        'stockQuantity': int.tryParse(_stockController.text) ?? 0,
        'description': _descController.text.isNotEmpty ? _descController.text : null,
        'mediaAssets': [...existingMedia, ...newMedia],
      };
      
      final ApiClient apiClient = getIt<ApiClient>();
      if (widget.product != null) {
        await apiClient.put('/shopkeeper/products/${widget.product!.id}', data: payload);
      } else {
        await apiClient.post('/shopkeeper/products', data: payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product added successfully with \${uploadResults.length} images!'),
            backgroundColor: AppColors.success500,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload images. Please try again.'),
            backgroundColor: AppColors.error500,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text('Add Product', style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved as draft')),
              );
            },
            child: Text('Draft', style: AppTextStyles.body.copyWith(color: AppColors.roleRetailer, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product Images', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.roleRetailer, style: BorderStyle.solid), // Should be dashed in reality
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.camera, color: AppColors.roleRetailer),
                          SizedBox(height: 4),
                          Text('Add Image', style: TextStyle(fontSize: 10, color: AppColors.roleRetailer)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ..._existingImages.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _buildExistingImageThumb(entry.value, index: entry.key),
                  )),
                  ..._selectedImages.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _buildImageThumb(entry.value, index: entry.key),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            AppTextField(
              controller: _nameController,
              label: 'Product Name',
              hintText: 'e.g. Sony Bravia 55 inch 4K TV',
              validator: (val) => ValidationUtils.validateRequired(val, fieldName: 'Product Name'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _brandController,
              label: 'Brand',
              hintText: 'e.g. Sony',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _categoryController,
              label: 'Category',
              hintText: 'Search categories...',
              prefixIcon: const Icon(LucideIcons.search, size: 20),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryBreadcrumb('Electronics > TV & Video'),
                _buildCategoryBreadcrumb('Mobiles'),
                _buildCategoryBreadcrumb('Computers'),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _mrpController,
                    label: 'MRP',
                    hintText: 'Rs. 0.00',
                    keyboardType: TextInputType.number,
                    validator: (val) => ValidationUtils.validatePrice(val, fieldName: 'MRP'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppTextField(
                    controller: _priceController,
                    label: 'Selling Price',
                    hintText: 'Rs. 0.00',
                    keyboardType: TextInputType.number,
                    validator: (val) => ValidationUtils.validatePrice(val, fieldName: 'Selling Price'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Inventory Tracking Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neutral300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Track Inventory', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                          Text('Automatically update stock levels', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                        ],
                      ),
                      Switch(
                        value: _trackInventory,
                        onChanged: (val) {
                          setState(() => _trackInventory = val);
                        },
                        activeThumbColor: AppColors.roleRetailer,
                      ),
                    ],
                  ),
                  if (_trackInventory) ...[
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _stockController,
                      label: 'Stock Quantity',
                      hintText: 'e.g. 50',
                      keyboardType: TextInputType.number,
                      validator: (val) => ValidationUtils.validateQuantity(val, fieldName: 'Stock'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Product Description', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.sparkles, size: 12, color: AppColors.success500),
                      const SizedBox(width: 4),
                      Text('AI Suggest', style: AppTextStyles.caption.copyWith(color: AppColors.success500, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the product features, specifications, and condition...',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.neutral400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.neutral300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.neutral300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.roleRetailer, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),

            AppButton(
              text: _isUploading ? 'Uploading & Publishing...' : 'Publish Product',
              icon: LucideIcons.uploadCloud,
              size: AppButtonSize.fullWidth,
              onPressed: _isUploading ? () {} : _publishProduct,
            ),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }


  Widget _buildExistingImageThumb(String url, {required int index}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.neutral200,
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _existingImages.removeAt(index);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                child: const Icon(LucideIcons.x, size: 12, color: AppColors.neutral900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumb(XFile file, {required int index}) {

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.neutral200,
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: kIsWeb ? NetworkImage(file.path) : FileImage(File(file.path)) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImages.removeAt(index);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                child: const Icon(LucideIcons.x, size: 12, color: AppColors.neutral900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreadcrumb(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _categoryController.text = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral300),
        ),
        child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.neutral700)),
      ),
    );
  }
}
