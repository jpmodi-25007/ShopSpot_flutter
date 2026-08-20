import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_badge.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../../../core/utils/guest_helper.dart';
import 'dart:ui';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isDetailsExpanded = true;

  @override
  void initState() {
    super.initState();
    context
        .read<ProductBloc>()
        .add(GetProductDetailRequested(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.arrowLeft,
                  size: 20, color: AppColors.neutral900),
            ),
            onPressed: () => context.pop(),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.heart,
                    size: 20, color: AppColors.neutral900),
              ),
              onPressed: () {
                if (GuestHelper.checkGuestAndPrompt(context)) return;
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductError) {
            return Center(
                child: Text(state.failure.message,
                    style: const TextStyle(color: Colors.red)));
          } else if (state is ProductDetailLoaded) {
            final product = state.product;
            final images = product.images.isNotEmpty
                ? product.images
                : ['invalid']; // To trigger errorBuilder

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Premium Edge-to-Edge Gallery Hero
                      SizedBox(
                        height: screenH * 0.55,
                        width: double.infinity,
                        child: PageView.builder(
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/web_lifestyle_shopping.jpg',
                                  fit: BoxFit.cover,
                                );
                              },
                            );
                          },
                        ),
                      ),
                      
                      // Product Info Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (product.brand != null)
                                  Text(product.brand!.toUpperCase(),
                                      style: AppTextStyles.caption.copyWith(
                                          color: AppColors.roleCustomer,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.5)),
                                if (product.stockQuantity > 0)
                                  AppBadge(
                                      type: AppBadgeType.inStock,
                                      text:
                                          '${product.stockQuantity} Left')
                                else
                                  const AppBadge(
                                      type: AppBadgeType.outOfStock,
                                      text: 'Sold Out'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(product.name,
                                style: AppTextStyles.h1.copyWith(
                                    fontSize: 28, height: 1.2)),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Rs.${product.sellingPrice}',
                                    style: AppTextStyles.h2.copyWith(
                                        color: AppColors.neutral900)),
                                if (product.mrp != null) ...[
                                  const SizedBox(width: 12),
                                  Text('Rs.${product.mrp}',
                                      style: AppTextStyles.priceStrikethrough
                                          .copyWith(
                                              color: AppColors.neutral400,
                                              fontSize: 18)),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: AppColors.error50,
                                        borderRadius:
                                            BorderRadius.circular(6)),
                                    child: Text(
                                        '${((1 - (product.sellingPrice / product.mrp!)) * 100).toStringAsFixed(0)}% OFF',
                                        style: AppTextStyles.caption.copyWith(
                                            color: AppColors.error500,
                                            fontWeight: FontWeight.w800)),
                                  )
                                ]
                              ],
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Premium Sold By Card
                            Text('Curated by', style: AppTextStyles.h4),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => context
                                  .push('/shop-detail/${product.shopId}'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.neutral900
                                          .withValues(alpha: 0.04),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.neutral200),
                                      ),
                                      child: ClipOval(
                                        child: Image.network(
                                          'invalid',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                              stackTrace) {
                                            return Image.asset(
                                                'assets/images/web_hero_boutique.jpg',
                                                fit: BoxFit.cover);
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text('The Style Studio',
                                                  style: AppTextStyles.body
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.w700)),
                                              const SizedBox(width: 6),
                                              const Icon(
                                                  LucideIcons.shieldCheck,
                                                  size: 16,
                                                  color: AppColors
                                                      .roleCustomer),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(LucideIcons.mapPin,
                                                  size: 12,
                                                  color:
                                                      AppColors.neutral500),
                                              const SizedBox(width: 4),
                                              Text('C.G. Road • 1.2km away',
                                                  style: AppTextStyles.caption
                                                      .copyWith(
                                                          color: AppColors
                                                              .neutral500)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: AppColors.neutral50,
                                          shape: BoxShape.circle),
                                      child: const Icon(
                                          LucideIcons.chevronRight,
                                          size: 20,
                                          color: AppColors.neutral700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            if (product.description != null &&
                                product.description!.isNotEmpty) ...[
                              const SizedBox(height: 40),
                              
                              // Expandable Details Accordion
                              Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  initiallyExpanded: _isDetailsExpanded,
                                  onExpansionChanged: (val) {
                                    setState(() => _isDetailsExpanded = val);
                                  },
                                  tilePadding: EdgeInsets.zero,
                                  title: Text('Product Details',
                                      style: AppTextStyles.h4),
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: Text(
                                        product.description!,
                                        style: AppTextStyles.body.copyWith(
                                            color: AppColors.neutral600,
                                            height: 1.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating Glassmorphism Bottom Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.8),
                          border: Border(
                              top: BorderSide(
                                  color: AppColors.neutral200
                                      .withValues(alpha: 0.5))),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: AppButton(
                                text: 'Negotiate',
                                variant: AppButtonVariant.outline,
                                onPressed: () {
                                  if (GuestHelper.checkGuestAndPrompt(
                                      context)) {
                                    return;
                                  }
                                  context.push('/negotiation');
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: AppButton(
                                text: 'Add to Cart',
                                variant: AppButtonVariant.primary,
                                onPressed: () {
                                  if (GuestHelper.checkGuestAndPrompt(
                                      context)) {
                                    return;
                                  }
                                  // Proceed with Buy
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
