import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/dependency_injection/injection.dart';
import 'features/authentication/presentation/bloc/authentication_bloc.dart';
import 'features/authentication/presentation/bloc/authentication_event.dart';
import 'features/authentication/presentation/bloc/authentication_state.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/retailer_inventory/presentation/bloc/retailer_inventory_bloc.dart';
import 'features/shop/presentation/bloc/shop_bloc.dart';
import 'features/retailer_dashboard/presentation/bloc/retailer_dashboard_bloc.dart';
import 'features/influencer/presentation/bloc/influencer_bloc.dart';
import 'features/negotiation/presentation/bloc/negotiation_bloc.dart';
import 'features/retailer_negotiation/presentation/bloc/retailer_negotiation_bloc.dart';
import 'features/retailer_campaigns/presentation/bloc/retailer_campaign_bloc.dart';
import 'features/dashboard/presentation/bloc/search_bloc.dart';
import 'features/dashboard/presentation/bloc/notification_bloc.dart';
import 'features/dashboard/presentation/bloc/promotion_bloc.dart';
import 'features/dashboard/presentation/bloc/event_bloc.dart';

import 'core/services/pending_notification_service.dart';
import 'core/services/notification_router.dart';

import 'core/widgets/mobile_web_app_banner.dart';
import 'core/widgets/connectivity_wrapper.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables. In production you might load .env.production
  const isProduction = bool.fromEnvironment('dart.vm.product');
  await dotenv.load(fileName: isProduction ? ".env.production" : ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await configureDependencies();
  runApp(const FindivoApp());
}

class FindivoApp extends StatelessWidget {
  const FindivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => getIt<AuthenticationBloc>()
              ..add(const CheckSessionRequested())),
        BlocProvider(create: (_) => getIt<ProductBloc>()),
        BlocProvider(create: (_) => getIt<RetailerInventoryBloc>()),
        BlocProvider(create: (_) => getIt<ShopBloc>()),
        BlocProvider(create: (_) => getIt<RetailerDashboardBloc>()),
        BlocProvider(create: (_) => getIt<InfluencerBloc>()),
        BlocProvider(create: (_) => getIt<NegotiationBloc>()),
        BlocProvider(create: (_) => getIt<RetailerNegotiationBloc>()),
        BlocProvider(create: (_) => getIt<RetailerCampaignBloc>()),
        BlocProvider(create: (_) => getIt<SearchBloc>()),
        BlocProvider(create: (_) => getIt<NotificationBloc>()),
        BlocProvider(create: (_) => getIt<PromotionBloc>()),
        BlocProvider(create: (_) => getIt<EventBloc>()),
      ],
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationLoaded) {
            // Upon successful authentication, check for pending deep-link/notification
            final pendingService = PendingNotificationService();
            if (pendingService.hasPendingNotification) {
              final payload = pendingService.consumePendingNotification();
              if (payload != null) {
                // Ensure we give the router a tiny delay to finish its own redirect
                Future.delayed(const Duration(milliseconds: 300), () {
                  NotificationRouter.handleNotificationTap(payload, context);
                });
              }
            }
          }
        },
        child: MaterialApp.router(
          title: 'Findivo',
          theme: AppTheme.lightTheme,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return ConnectivityWrapper(
              child: MobileWebAppBanner(child: child!),
            );
          },
        ),
      ),
    );
  }
}
