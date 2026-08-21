import 'package:flutter/material.dart';
import 'package:mobile_web/core/widgets/shimmer_effects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../saved/presentation/bloc/saved_bloc.dart';
import '../../../saved/presentation/bloc/saved_event.dart';
import '../../../saved/presentation/bloc/saved_state.dart';

class SavedShopsScreen extends StatelessWidget {
  const SavedShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SavedBloc>()..add(const GetSavedShopsRequested()),
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
              return const GenericListShimmer();
            }
            final shops = state is SavedLoaded ? state.savedShops ?? [] : [];
            if (shops.isEmpty) {
              return Center(
                child: Text('No saved shops yet', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: shops.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final shop = shops[index];
                final imageUrl = (shop['logo'] != null && shop['logo'].isNotEmpty)
                    ? shop['logo']
                    : 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=200&auto=format&fit=crop';
                final rating = shop['rating'] ?? 5.0;
                final totalReviews = shop['totalReviews'] ?? 0;

                return Container(
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
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(shop['name'] ?? '', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                GestureDetector(
                                  onTap: () {
                                    context.read<SavedBloc>().add(RemoveSavedShopRequested(shop['id']));
                                  },
                                  child: Icon(Icons.favorite, color: AppColors.error500, size: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(shop['category'] ?? '', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(LucideIcons.star, color: AppColors.warning500, size: 16),
                                const SizedBox(width: 4),
                                Text('$rating ($totalReviews reviews)', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                              ],
                            ),
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
