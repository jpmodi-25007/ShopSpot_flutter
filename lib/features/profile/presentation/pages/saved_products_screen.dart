import 'package:flutter/material.dart';
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
              return const Center(child: CircularProgressIndicator());
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
                final imageUrl = (product['images'] != null && (product['images'] as List).isNotEmpty) 
                    ? product['images'][0] 
                    : 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=300&auto=format&fit=crop';

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
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  context.read<SavedBloc>().add(RemoveSavedProductRequested(product['id']));
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 16,
                                  child: Icon(Icons.favorite, color: AppColors.error500, size: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product['name'] ?? '', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(product['category'] ?? '', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                            const SizedBox(height: 8),
                            Text('₹${product['price'] ?? 0}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary500)),
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
