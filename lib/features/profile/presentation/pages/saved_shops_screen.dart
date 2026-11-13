import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/animated_fade_slide.dart';
import '../../../../core/widgets/app_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../saved/presentation/bloc/saved_bloc.dart';
import '../../../saved/presentation/bloc/saved_event.dart';
import '../../../saved/presentation/bloc/saved_state.dart';

class SavedShopsScreen extends StatelessWidget {
  const SavedShopsScreen({super.key});

  String? _shopImageUrl(Map shop) {
    for (final key in ['logoUrl', 'logo', 'coverImageUrl', 'imageUrl']) {
      final value = shop[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<SavedBloc>()..add(const GetSavedShopsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: AppBar(
          title: Text('Saved Shops', style: AppTextStyles.h4),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: BlocBuilder<SavedBloc, SavedState>(
          builder: (context, state) {
            if (state is SavedLoaded && state.isLoading) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 6,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) =>
                    const ProductListItemSkeleton(),
              );
            }
            final shops = state is SavedLoaded ? state.savedShops ?? [] : [];
            if (shops.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.store, size: 40, color: AppColors.neutral300),
                    const SizedBox(height: 12),
                    Text(
                      'No saved shops yet',
                      style: AppTextStyles.body.copyWith(color: AppColors.neutral500),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: shops.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final shop = shops[index];
                final imageUrl = _shopImageUrl(Map<String, dynamic>.from(shop as Map));
                final rating = shop['rating'] ?? 5.0;
                final totalReviews = shop['totalReviews'] ?? shop['reviewCount'] ?? 0;
                final shopId = '${shop['id'] ?? ''}';
                final category = shop['category'] is Map
                    ? (shop['category']['name'] ?? '')
                    : (shop['category'] ?? shop['city'] ?? '');

                return AnimatedFadeSlide(
                  key: ValueKey('saved-shop-$shopId'),
                  delay: staggerDelay(index),
                  child: PressableScale(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: shopId.isEmpty
                          ? null
                          : () => context.push('/shop-detail/$shopId'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
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
                        child: Row(
                          children: [
                            AppNetworkImage(
                              url: imageUrl,
                              width: 80,
                              height: 80,
                              borderRadius: BorderRadius.circular(12),
                              placeholderIcon: LucideIcons.store,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: Text(shop['name'] ?? '',
                                              style: AppTextStyles.body
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis)),
                                      GestureDetector(
                                        onTap: () {
                                          context.read<SavedBloc>().add(
                                              RemoveSavedShopRequested(
                                                  shop['id']));
                                        },
                                        child: const Icon(Icons.favorite,
                                            color: AppColors.error500,
                                            size: 20),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('$category',
                                      style: AppTextStyles.caption.copyWith(
                                          color: AppColors.neutral500)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.star,
                                          color: AppColors.warning500,
                                          size: 16),
                                      const SizedBox(width: 4),
                                      Text('$rating ($totalReviews reviews)',
                                          style: AppTextStyles.caption.copyWith(
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
