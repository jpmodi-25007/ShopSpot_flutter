import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import '../../../../core/widgets/app_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../saved/presentation/bloc/saved_bloc.dart';
import '../../../saved/presentation/bloc/saved_event.dart';
import '../../../saved/presentation/bloc/saved_state.dart';

class SavedProductsScreen extends StatelessWidget {
  const SavedProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SavedBloc>()..add(const GetSavedProductsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: AppBar(
          title: Text('Saved Products', style: AppTextStyles.h4),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: BlocBuilder<SavedBloc, SavedState>(
          builder: (context, state) {
            if (state is SavedLoaded && state.isLoading) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => const ProductCardSkeleton(),
              );
            }
            final products = state is SavedLoaded ? state.savedProducts ?? [] : [];
            if (products.isEmpty) {
              return Center(
                child: Text('No saved products yet', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                // Try multiple possible keys based on backend payload
                final name = product['name'] ?? product['productName'] ?? 'Product';
                final price = product['sellingPrice'] ?? product['price'] ?? 0;
                final category = product['category'] ?? product['shopName'] ?? '';
                final images = product['images'] as List?;
                final imageUrl = (images != null && images.isNotEmpty) 
                    ? images[0] 
                    : '';

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AppNetworkImage(
                              url: imageUrl.isNotEmpty ? imageUrl : null,
                              fit: BoxFit.cover,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  context.read<SavedBloc>().add(RemoveSavedProductRequested(product['productId'] ?? product['id'] ?? ''));
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 16,
                                  child: Icon(Icons.favorite, color: AppColors.error500, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$name', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (category.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('$category', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                            const SizedBox(height: 8),
                            Text('₹$price', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
