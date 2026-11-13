import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/animated_fade_slide.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/network/api_client.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _hasQuery = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  Timer? _debounce;
  static const String _recentSearchesKey = 'recent_searches_key';

  List<String> _recentSearches = [];
  List<_SearchCategory> _categories = [];
  List<String> _trending = [];
  bool _loadingDiscover = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _controller.text = widget.initialQuery!;
      _hasQuery = true;
      _addToRecentSearches(widget.initialQuery!);
      context
          .read<SearchBloc>()
          .add(PerformSearchRequested(widget.initialQuery!));
    }
    _loadRecentSearches();
    _loadDiscover();
  }

  IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('fashion')) return LucideIcons.shirt;
    if (n.contains('jewel')) return LucideIcons.gem;
    if (n.contains('beauty') || n.contains('health')) return LucideIcons.sparkles;
    if (n.contains('home') || n.contains('garden')) return LucideIcons.home;
    if (n.contains('food') || n.contains('beverage')) return LucideIcons.coffee;
    if (n.contains('electron')) return LucideIcons.monitor;
    if (n.contains('sport')) return LucideIcons.activity;
    if (n.contains('art')) return LucideIcons.palette;
    return LucideIcons.tag;
  }

  Future<void> _loadDiscover() async {
    try {
      final api = getIt<ApiClient>();
      final categoriesRes = await api.get('/categories');
      final trendingRes = await api.get('/products/trending', queryParameters: {'limit': 8});
      final rawCategories = categoriesRes.data;
      final categoryList = rawCategories is List ? rawCategories : <dynamic>[];
      final rawTrending = trendingRes.data;
      final trendingList = rawTrending is List
          ? rawTrending
          : (rawTrending is Map ? (rawTrending['data'] ?? []) : <dynamic>[]);
      if (!mounted) return;
      setState(() {
        _categories = categoryList.whereType<Map>().map((item) {
          final name = item['name']?.toString() ?? '';
          return _SearchCategory(name, _iconForCategory(name));
        }).where((c) => c.name.isNotEmpty).toList();
        _trending = (trendingList as List)
            .whereType<Map>()
            .map((item) => item['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .take(8)
            .toList();
        _loadingDiscover = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingDiscover = false);
    }
  }

  void _runSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.length < 2) return;
    _controller.text = trimmed;
    _controller.selection = TextSelection.collapsed(offset: trimmed.length);
    setState(() => _hasQuery = true);
    context.read<SearchBloc>().add(PerformSearchRequested(trimmed));
    _addToRecentSearches(trimmed);
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
    });
  }

  Future<void> _addToRecentSearches(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_recentSearchesKey) ?? [];
    searches.remove(query);
    searches.insert(0, query);
    if (searches.length > 10) {
      searches.removeLast();
    }
    setState(() {
      _recentSearches = searches;
    });
    await prefs.setStringList(_recentSearchesKey, searches);
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
    setState(() {
      _recentSearches = [];
    });
  }

  Future<void> _removeFromRecentSearches(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_recentSearchesKey) ?? [];
    searches.remove(query);
    setState(() {
      _recentSearches = searches;
    });
    await prefs.setStringList(_recentSearchesKey, searches);
  }

  @override
  void didUpdateWidget(SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != oldWidget.initialQuery &&
        widget.initialQuery != null &&
        widget.initialQuery!.isNotEmpty) {
      if (_controller.text != widget.initialQuery) {
        _controller.text = widget.initialQuery!;
        setState(() => _hasQuery = true);
        _addToRecentSearches(widget.initialQuery!);
        context
            .read<SearchBloc>()
            .add(PerformSearchRequested(widget.initialQuery!));
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_hasQuery && _controller.text.isNotEmpty) {
      context.read<SearchBloc>().add(PerformSearchRequested(_controller.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header with Floating Search Input
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral900.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Discover',
                      style: AppTextStyles.h1
                          .copyWith(color: AppColors.neutral900)),
                  Text('Find curated boutiques & products',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.neutral500)),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.neutral200.withValues(alpha: 0.5)),
                    ),
                    child: TextField(
                      controller: _controller,
                      autofocus: false,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600),
                      onSubmitted: _runSearch,
                      onChanged: (val) {
                        setState(() => _hasQuery = val.trim().isNotEmpty);
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(milliseconds: 400), () {
                          final trimmed = val.trim();
                          if (trimmed.length < 2) {
                            context.read<SearchBloc>().add(const PerformSearchRequested(''));
                            return;
                          }
                          context.read<SearchBloc>().add(PerformSearchRequested(trimmed));
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search for styles, shops...',
                        hintStyle: AppTextStyles.body
                            .copyWith(color: AppColors.neutral400),
                        prefixIcon: const Icon(LucideIcons.search,
                            color: AppColors.neutral900, size: 20),
                        suffixIcon: _hasQuery
                            ? IconButton(
                                icon: const Icon(LucideIcons.x,
                                    color: AppColors.neutral900, size: 18),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() => _hasQuery = false);
                                },
                              )
                            : const Icon(LucideIcons.slidersHorizontal,
                                color: AppColors.neutral900, size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _hasQuery ? _buildResults() : _buildDiscover(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscover() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Searches',
                    style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
                TextButton(
                  onPressed: _clearRecentSearches,
                  child: Text('Clear',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.neutral500)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _recentSearches.map((search) {
                return _AnimatedChip(
                  label: search,
                  icon: LucideIcons.clock,
                  onTap: () {
                    _controller.text = search;
                    setState(() => _hasQuery = true);
                    context.read<SearchBloc>().add(PerformSearchRequested(search));
                    _addToRecentSearches(search);
                  },
                  onDelete: () => _removeFromRecentSearches(search),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],

          Text('Categories',
              style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: 20),
          if (_loadingDiscover)
            const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ))
          else if (_categories.isEmpty)
            Text('No categories yet.',
                style: AppTextStyles.body.copyWith(color: AppColors.neutral500))
          else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              childAspectRatio: 0.8,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 60)),
                curve: Curves.easeOut,
                builder: (context, val, child) => Transform.translate(
                  offset: Offset(0, 20 * (1 - val)),
                  child: Opacity(opacity: val, child: child),
                ),
                child: _CategoryTile(
                  category: category,
                  onTap: () => _runSearch(category.name),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // Trending Near You
          Text('Trending',
              style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: 16),
          if (_trending.isEmpty && !_loadingDiscover)
            Text('No trending products yet.',
                style: AppTextStyles.body.copyWith(color: AppColors.neutral500))
          else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _trending
                .map((t) => _TrendingChip(label: t, onTap: () => _runSearch(t)))
                .toList(),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) => const SearchResultSkeleton(),
          );
        } else if (state is SearchError) {
          return Center(
              child: Text(state.message,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.error500)));
        } else if (state is SearchLoaded) {
          final results = state.results;
          if (results.shops.isEmpty &&
              results.products.isEmpty &&
              results.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.searchX, size: 48, color: AppColors.neutral300),
                  const SizedBox(height: 16),
                  Text("No results found.", style: AppTextStyles.bodyLarge),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            children: [
              if (results.categories.isNotEmpty) ...[
                Text('Categories', style: AppTextStyles.h4),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: results.categories
                      .map((c) => _TrendingChip(label: c.name, onTap: () => _runSearch(c.name)))
                      .toList(),
                ),
                const SizedBox(height: 32),
              ],
              if (results.shops.isNotEmpty) ...[
                Text('Boutiques', style: AppTextStyles.h4),
                const SizedBox(height: 12),
                ...results.shops.asMap().entries.map((entry) => AnimatedFadeSlide(
                      delay: Duration(milliseconds: 50 * entry.key),
                      child: _SearchResultCard(
                        name: entry.value.name,
                        subtitle: '${entry.value.city}',
                        rating: entry.value.rating,
                        imageUrl: entry.value.logoUrl ?? '',
                        onTap: () async {
                          await context.push('/shop-detail/${entry.value.id}');
                          if (mounted) _refresh();
                        },
                      ),
                    )),
                const SizedBox(height: 24),
              ],
              if (results.products.isNotEmpty) ...[
                Text('Products', style: AppTextStyles.h4),
                const SizedBox(height: 12),
                ...results.products.asMap().entries.map((entry) => AnimatedFadeSlide(
                      delay: Duration(milliseconds: 50 * entry.key),
                      child: _SearchResultCard(
                        name: entry.value.name,
                        subtitle: '₹${entry.value.sellingPrice}',
                        rating: 0.0,
                        imageUrl: entry.value.images.isNotEmpty
                            ? entry.value.images.first
                            : '',
                        onTap: () async {
                          await context.push('/product-detail/${entry.value.id}');
                          if (mounted) _refresh();
                        },
                      ),
                    )),
              ],
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SearchCategory {
  final String name;
  final IconData icon;
  const _SearchCategory(this.name, this.icon);
}

class _CategoryTile extends StatefulWidget {
  final _SearchCategory category;
  final VoidCallback? onTap;
  const _CategoryTile({required this.category, this.onTap});
  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral900.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: Icon(widget.category.icon,
                    color: AppColors.neutral700, size: 24),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.category.name,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.neutral700, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _AnimatedChip(
      {required this.label,
      required this.icon,
      required this.onTap,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.neutral400),
            const SizedBox(width: 8),
            Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.neutral700)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(LucideIcons.x,
                  size: 14, color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _TrendingChip({required this.label, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.roleCustomerLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: AppColors.roleCustomer.withValues(alpha: 0.2)),
        ),
        child: Text(label,
            style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.roleCustomer, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final double rating;
  final String imageUrl;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            AppNetworkImage(
              url: imageUrl.isNotEmpty ? imageUrl : null,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: AppTextStyles.h4.copyWith(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.neutral500)),
                    if (rating > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(LucideIcons.star,
                              size: 14, color: AppColors.secondary500),
                          const SizedBox(width: 4),
                          Text('$rating',
                              style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(LucideIcons.chevronRight,
                  color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}
