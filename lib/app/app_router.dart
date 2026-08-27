import '../../features/profile/presentation/pages/help_support_screen.dart';
import '../../features/profile/presentation/pages/about_findivo_screen.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/dependency_injection/injection.dart';
import '../../features/authentication/presentation/pages/splash_screen.dart';
import '../../features/authentication/presentation/pages/intro_screen.dart';


import '../../features/authentication/presentation/pages/login_screen.dart';
import '../../features/authentication/presentation/pages/signup_screen.dart';
import '../../features/authentication/presentation/pages/forgot_password_screen.dart';
import '../../features/dashboard/presentation/pages/home_feed_screen.dart';
import '../../features/dashboard/presentation/pages/map_view_screen.dart';
import '../../features/dashboard/presentation/pages/search_screen.dart';
import '../../features/dashboard/presentation/pages/chats_screen.dart';
import '../../features/dashboard/presentation/pages/notifications_screen.dart';
import '../../features/product/presentation/pages/product_detail_screen.dart';
import '../../features/shop/presentation/pages/shop_detail_screen.dart';
import '../../features/negotiation/presentation/pages/negotiation_chat_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/profile/presentation/pages/my_reservations_screen.dart';
import '../../features/profile/presentation/pages/my_orders_screen.dart';
import '../../features/profile/presentation/pages/saved_products_screen.dart';
import '../../features/profile/presentation/pages/saved_shops_screen.dart';
import '../../features/profile/presentation/pages/manage_addresses_screen.dart';
import '../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../../features/retailer_dashboard/presentation/pages/retailer_dashboard_screen.dart';
import '../../features/retailer_dashboard/presentation/pages/retailer_profile_screen.dart';
import '../../features/dashboard/presentation/pages/events_list_screen.dart';
import '../../features/dashboard/presentation/pages/event_details_screen.dart';
import '../../features/dashboard/presentation/pages/retailer_create_event_screen.dart';
import '../../features/retailer_inventory/presentation/pages/product_management_screen.dart';
import '../../features/retailer_inventory/presentation/pages/add_product_screen.dart';
import '../../features/retailer_inventory/presentation/pages/stock_history_screen.dart';
import '../../features/retailer_inventory/presentation/pages/bulk_management_screen.dart';
import '../../features/retailer_inventory/presentation/pages/supplier_management_screen.dart';
import '../../features/retailer_negotiation/presentation/pages/retailer_negotiations_screen.dart';
import '../../features/retailer_negotiation/presentation/pages/retailer_negotiation_chat_screen.dart';
import '../../features/retailer_campaigns/presentation/pages/retailer_campaigns_screen.dart';
import '../../features/retailer_campaigns/presentation/pages/create_campaign_screen.dart';
import '../../features/retailer_campaigns/presentation/pages/campaign_bids_screen.dart';
import '../../features/retailer_campaigns/presentation/pages/retailer_influencer_profile_screen.dart';
import '../../features/order/presentation/pages/retailer_orders_screen.dart';
import '../../features/order/presentation/bloc/retailer_order_bloc.dart';
import '../../features/influencer/presentation/pages/influencer_discover_screen.dart';
import '../../features/influencer/presentation/pages/influencer_dashboard_screen.dart';
import '../../features/influencer/presentation/pages/influencer_earnings_screen.dart';
import '../../features/influencer/presentation/pages/influencer_profile_screen.dart';
import '../../features/influencer/presentation/pages/campaign_details_screen.dart';
import '../../features/influencer/presentation/pages/submit_bid_screen.dart';
import '../../features/influencer/presentation/pages/influencer_pending_screen.dart';
import '../../features/influencer/domain/entities/influencer_campaign_entity.dart';
import 'shell_layout.dart';
import 'retailer_shell_layout.dart';
import 'influencer_shell_layout.dart';
import 'package:flutter/foundation.dart';
import '../web/layouts/web_layout.dart';

import '../web/pages/home_page.dart';
import '../web/pages/features_page.dart';
import '../web/pages/how_it_works_page.dart';
import '../web/pages/about_page.dart';
import '../web/pages/faq_page.dart';
import '../web/pages/contact_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: kIsWeb ? '/' : '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/intro',
      builder: (context, state) => const IntroScreen(),
    ),

    // WEB ROUTES
    ShellRoute(
      builder: (context, state, child) => WebLayout(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const WebHomePage(),
        ),
        GoRoute(
          path: '/features',
          builder: (context, state) => const WebFeaturesPage(),
        ),
        GoRoute(
          path: '/how-it-works',
          builder: (context, state) => const WebHowItWorksPage(),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const WebAboutPage(),
        ),
        GoRoute(
          path: '/faq',
          builder: (context, state) => const WebFAQPage(),
        ),
        GoRoute(
          path: '/contact',
          builder: (context, state) => const WebContactPage(),
        ),
      ],
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) {
        final role = state.uri.queryParameters['role'];
        return SignupScreen(initialRole: role);
      },
    ),
    GoRoute(
      path: '/product-detail/:id',
      builder: (context, state) => ProductDetailScreen(productId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/events',
      builder: (context, state) => const EventsListScreen(),
    ),
    GoRoute(
      path: '/events/:id',
      builder: (context, state) => EventDetailsScreen(eventId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/shop-detail/:id',
      builder: (context, state) => ShopDetailScreen(shopId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/negotiation/:id',
      builder: (context, state) => NegotiationChatScreen(negotiationId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/reservations',
      builder: (context, state) => const MyReservationsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/my-orders',
      builder: (context, state) => const MyOrdersScreen(),
    ),
    GoRoute(
      path: '/saved-products',
      builder: (context, state) => const SavedProductsScreen(),
    ),
    GoRoute(
      path: '/help-support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/about-findivo',
      builder: (context, state) => const AboutFindivoScreen(),
    ),
    GoRoute(
      path: '/saved-shops',
      builder: (context, state) => const SavedShopsScreen(),
    ),
    GoRoute(
      path: '/manage-addresses',
      builder: (context, state) => const ManageAddressesScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    
    // CUSTOMER SHELL
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeFeedScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => SearchScreen(initialQuery: state.uri.queryParameters['q']),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapViewScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chats',
              builder: (context, state) => const ChatsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // RETAILER SHELL
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return RetailerShellLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/retailer/home',
              builder: (context, state) => const RetailerDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/retailer/inventory',
              builder: (context, state) => const ProductManagementScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/retailer/negotiations',
              builder: (context, state) => const RetailerNegotiationsScreen(),
            ),
            GoRoute(
              path: '/retailer/negotiations/:id',
              builder: (context, state) => RetailerNegotiationChatScreen(negotiationId: state.pathParameters['id']!),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/retailer/profile',
              builder: (context, state) => const RetailerProfileScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/retailer/campaigns',
              builder: (context, state) => const RetailerCampaignsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/retailer/orders',
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<RetailerOrderBloc>(),
                child: const RetailerOrdersScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    
    // RETAILER STANDALONE ROUTES
    GoRoute(
      path: '/retailer/add-product',
      builder: (context, state) => const AddProductScreen(),
    ),
    GoRoute(
      path: '/retailer/events/create',
      builder: (context, state) => const RetailerCreateEventScreen(),
    ),
    GoRoute(
      path: '/retailer/stock-history',
      builder: (context, state) => const StockHistoryScreen(),
    ),
    GoRoute(
      path: '/retailer/bulk-update',
      builder: (context, state) => const BulkManagementScreen(),
    ),
    GoRoute(
      path: '/retailer/suppliers',
      builder: (context, state) => const SupplierManagementScreen(),
    ),
    GoRoute(
      path: '/retailer/create-campaign',
      builder: (context, state) => const CreateCampaignScreen(),
    ),
    GoRoute(
      path: '/retailer/campaigns/:id/bids',
      builder: (context, state) => CampaignBidsScreen(campaignId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/retailer/influencer-profile/:id',
      builder: (context, state) => RetailerInfluencerProfileScreen(influencerId: state.pathParameters['id']!),
    ),
    
    // INFLUENCER SHELL
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return InfluencerShellLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/influencer/home', // This acts as Discover
              builder: (context, state) => const InfluencerDiscoverScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/influencer/campaigns',
              builder: (context, state) => const InfluencerDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/influencer/earnings',
              builder: (context, state) => const InfluencerEarningsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/influencer/profile',
              builder: (context, state) => const InfluencerProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // INFLUENCER STANDALONE ROUTES
    GoRoute(
      path: '/influencer/campaign-details',
      builder: (context, state) {
        final campaign = state.extra as InfluencerCampaignEntity?;
        return CampaignDetailsScreen(campaign: campaign);
      },
    ),
    GoRoute(
      path: '/influencer/submit-bid',
      builder: (context, state) {
        final campaign = state.extra as InfluencerCampaignEntity?;
        return SubmitBidScreen(campaign: campaign);
      },
    ),
    GoRoute(
      path: '/influencer/pending',
      builder: (context, state) => const InfluencerPendingScreen(),
    ),
  ],
);
