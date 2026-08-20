import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/dependency_injection/injection.dart';
import 'features/authentication/presentation/bloc/authentication_bloc.dart';
import 'features/authentication/presentation/bloc/authentication_event.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const ShopSpotApp());
}

class ShopSpotApp extends StatelessWidget {
  const ShopSpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthenticationBloc>()..add(const CheckSessionRequested())),
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
      ],
      child: MaterialApp.router(
        title: 'ShopSpot',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
