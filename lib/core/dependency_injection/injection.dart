import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/auth_interceptor.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../services/push_notification_service.dart';
import '../services/cloudinary_service.dart';
import '../../features/dashboard/domain/usecases/mark_all_as_read_usecase.dart';

import '../../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/login_use_case.dart';
import '../../features/authentication/domain/usecases/register_use_case.dart';
import '../../features/authentication/domain/usecases/check_session_use_case.dart';
import '../../features/authentication/domain/usecases/logout_use_case.dart';
import '../../features/authentication/domain/usecases/update_profile_use_case.dart';
import '../../features/authentication/presentation/bloc/authentication_bloc.dart';

import '../../features/dashboard/data/datasources/event_remote_data_source.dart';
import '../../features/dashboard/presentation/bloc/event_bloc.dart';

import '../../features/product/data/datasources/product_remote_data_source.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/search_products_use_case.dart';
import '../../features/product/domain/usecases/get_trending_products_use_case.dart';
import '../../features/product/domain/usecases/get_product_detail_use_case.dart';
import '../../features/product/domain/usecases/get_price_comparison_use_case.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';

import '../../features/order/data/datasources/order_remote_data_source.dart';
import '../../features/order/data/repositories/order_repository_impl.dart';
import '../../features/order/domain/repositories/order_repository.dart';
import '../../features/order/domain/usecases/get_my_orders_use_case.dart';
import '../../features/order/presentation/bloc/order_bloc.dart';
import '../../features/order/presentation/bloc/retailer_order_bloc.dart';

import '../../features/reservation/data/datasources/reservation_remote_data_source.dart';
import '../../features/reservation/data/repositories/reservation_repository_impl.dart';
import '../../features/reservation/domain/repositories/reservation_repository.dart';
import '../../features/reservation/domain/usecases/get_my_reservations_use_case.dart';
import '../../features/reservation/presentation/bloc/reservation_bloc.dart';

import '../../features/retailer_inventory/data/datasources/retailer_inventory_remote_data_source.dart';
import '../../features/retailer_inventory/data/repositories/retailer_inventory_repository_impl.dart';
import '../../features/retailer_inventory/domain/repositories/retailer_inventory_repository.dart';
import '../../features/retailer_inventory/domain/usecases/get_my_products_use_case.dart';
import '../../features/retailer_inventory/domain/usecases/create_product_use_case.dart';
import '../../features/retailer_inventory/domain/usecases/update_product_use_case.dart';
import '../../features/retailer_inventory/domain/usecases/delete_product_use_case.dart';
import '../../features/retailer_inventory/domain/usecases/update_stock_use_case.dart';
import '../../features/retailer_inventory/domain/usecases/get_suppliers_use_case.dart';
import '../../features/retailer_inventory/domain/usecases/create_supplier_use_case.dart';
import '../../features/retailer_inventory/domain/usecases/get_purchase_orders_use_case.dart';
import '../../features/retailer_inventory/domain/usecases/get_stock_history_use_case.dart';
import '../../features/retailer_inventory/presentation/bloc/retailer_inventory_bloc.dart';

import '../../features/shop/data/datasources/shop_remote_data_source.dart';
import '../../features/shop/data/repositories/shop_repository_impl.dart';
import '../../features/shop/domain/repositories/shop_repository.dart';
import '../../features/shop/domain/usecases/get_public_shop_use_case.dart';
import '../../features/shop/domain/usecases/get_shop_products_use_case.dart';
import '../../features/shop/domain/usecases/get_nearby_shops_use_case.dart';
import '../../features/shop/presentation/bloc/shop_bloc.dart';

import '../../features/retailer_dashboard/data/datasources/retailer_dashboard_remote_data_source.dart';
import '../../features/retailer_dashboard/data/repositories/retailer_dashboard_repository_impl.dart';
import '../../features/retailer_dashboard/domain/repositories/retailer_dashboard_repository.dart';
import '../../features/retailer_dashboard/domain/usecases/retailer_dashboard_use_cases.dart';
import '../../features/retailer_dashboard/presentation/bloc/retailer_dashboard_bloc.dart';

import '../../features/influencer/data/datasources/influencer_remote_data_source.dart';
import '../../features/influencer/data/datasources/influencer_analytics_remote_data_source.dart';
import '../../features/influencer/data/repositories/influencer_repository_impl.dart';
import '../../features/influencer/data/repositories/influencer_analytics_repository_impl.dart';
import '../../features/influencer/domain/repositories/influencer_repository.dart';
import '../../features/influencer/domain/repositories/influencer_analytics_repository.dart';
import '../../features/influencer/domain/usecases/influencer_use_cases.dart';
import '../../features/influencer/domain/usecases/get_influencer_analytics_use_case.dart';
import '../../features/influencer/presentation/bloc/influencer_bloc.dart';

import '../../features/negotiation/data/datasources/negotiation_remote_data_source.dart';
import '../../features/negotiation/data/repositories/negotiation_repository_impl.dart';
import '../../features/negotiation/domain/repositories/negotiation_repository.dart';
import '../../features/negotiation/domain/usecases/negotiation_use_cases.dart';
import '../../features/negotiation/presentation/bloc/negotiation_bloc.dart';
import '../../features/retailer_negotiation/presentation/bloc/retailer_negotiation_bloc.dart';
import '../../features/retailer_campaigns/data/datasources/retailer_campaign_remote_data_source.dart';
import '../../features/retailer_campaigns/data/repositories/retailer_campaign_repository_impl.dart';
import '../../features/retailer_campaigns/domain/repositories/retailer_campaign_repository.dart';
import '../../features/retailer_campaigns/domain/usecases/retailer_campaign_usecases.dart';
import '../../features/retailer_campaigns/presentation/bloc/retailer_campaign_bloc.dart';
import '../../features/dashboard/data/datasources/search_remote_data_source.dart';
import '../../features/dashboard/data/repositories/search_repository_impl.dart';
import '../../features/dashboard/domain/repositories/search_repository.dart';
import '../../features/dashboard/domain/usecases/global_search_usecase.dart';
import '../../features/dashboard/presentation/bloc/search_bloc.dart';
import '../../features/dashboard/data/datasources/notification_remote_data_source.dart';
import '../../features/dashboard/data/repositories/notification_repository_impl.dart';
import '../../features/dashboard/domain/repositories/notification_repository.dart';
import '../../features/dashboard/domain/usecases/get_my_notifications_usecase.dart';
import '../../features/dashboard/presentation/bloc/notification_bloc.dart';
import '../../features/dashboard/data/repositories/promotion_repository_impl.dart';
import '../../features/dashboard/domain/repositories/promotion_repository.dart';
import '../../features/dashboard/presentation/bloc/promotion_bloc.dart';

import '../../features/saved/data/datasources/saved_remote_data_source.dart';
import '../../features/saved/data/repositories/saved_repository_impl.dart';
import '../../features/saved/domain/repositories/saved_repository.dart';
import '../../features/saved/domain/usecases/saved_use_cases.dart';
import '../../features/saved/presentation/bloc/saved_bloc.dart';

import '../../features/addresses/data/datasources/addresses_remote_data_source.dart';
import '../../features/addresses/data/repositories/addresses_repository_impl.dart';
import '../../features/addresses/domain/repositories/addresses_repository.dart';
import '../../features/addresses/domain/usecases/addresses_use_cases.dart';
import '../../features/addresses/presentation/bloc/addresses_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Storage
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<LocalStorage>(() => SharedPrefsLocalStorage(getIt()));
  
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  getIt.registerLazySingleton<SecureStorage>(() => FlutterSecureStorageImpl(getIt()));

  // Network
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    dio.interceptors.add(AuthInterceptor(getIt(), dio));
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    return dio;
  });
  getIt.registerLazySingleton<ApiClient>(() => DioApiClient(getIt()));

  // Services
  getIt.registerLazySingleton<Logger>(() => Logger());
  getIt.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(getIt<Dio>(), getIt<Logger>()),
  );

  // Features (Auth)
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt(), secureStorage: getIt()));
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
            remoteDataSource: getIt(),
            secureStorage: getIt(),
          ));
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => CheckSessionUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProfileUseCase(getIt()));
  getIt.registerFactory(() => AuthenticationBloc(
        loginUseCase: getIt(),
        registerUseCase: getIt(),
        checkSessionUseCase: getIt(),
        logoutUseCase: getIt(),
        updateProfileUseCase: getIt(),
      ));

  // Features (Product)
  getIt.registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton(() => SearchProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetTrendingProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetProductDetailUseCase(getIt()));
  getIt.registerLazySingleton(() => GetPriceComparisonUseCase(getIt()));
  getIt.registerFactory(() => ProductBloc(
        searchProductsUseCase: getIt(),
        getTrendingProductsUseCase: getIt(),
        getProductDetailUseCase: getIt(),
        getPriceComparisonUseCase: getIt(),
      ));

  // Features (Order)
  getIt.registerLazySingleton<OrderRemoteDataSource>(
      () => OrderRemoteDataSourceImpl(apiClient: getIt()));
  getIt.registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton(() => GetMyOrdersUseCase(getIt()));
  getIt.registerFactory(() => OrderBloc(getMyOrdersUseCase: getIt()));
  getIt.registerFactory(() => RetailerOrderBloc(getIt<OrderRemoteDataSource>()));

  // Features (Reservation)
  getIt.registerLazySingleton<ReservationRemoteDataSource>(
      () => ReservationRemoteDataSourceImpl(apiClient: getIt()));
  getIt.registerLazySingleton<ReservationRepository>(
      () => ReservationRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton(() => GetMyReservationsUseCase(getIt()));
  getIt.registerFactory(() => ReservationBloc(getMyReservationsUseCase: getIt()));

  // Features (Retailer Inventory)
  getIt.registerLazySingleton<RetailerInventoryRemoteDataSource>(
      () => RetailerInventoryRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<RetailerInventoryRepository>(
      () => RetailerInventoryRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton(() => GetMyProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateProductUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProductUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteProductUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateStockUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSuppliersUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateSupplierUseCase(getIt()));
  getIt.registerLazySingleton(() => GetPurchaseOrdersUseCase(getIt()));
  getIt.registerLazySingleton(() => GetStockHistoryUseCase(getIt()));
  getIt.registerFactory(() => RetailerInventoryBloc(
        getMyProductsUseCase: getIt(),
        createProductUseCase: getIt(),
        updateProductUseCase: getIt(),
        deleteProductUseCase: getIt(),
        updateStockUseCase: getIt(),
        getSuppliersUseCase: getIt(),
        createSupplierUseCase: getIt(),
        getPurchaseOrdersUseCase: getIt(),
        getStockHistoryUseCase: getIt(),
      ));

  // Features (Shop - Public)
  getIt.registerLazySingleton<ShopRemoteDataSource>(
      () => ShopRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<ShopRepository>(
      () => ShopRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton(() => GetPublicShopUseCase(getIt()));
  getIt.registerLazySingleton(() => GetShopProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetNearbyShopsUseCase(getIt()));
  getIt.registerFactory(() => ShopBloc(
        getPublicShopUseCase: getIt(),
        getShopProductsUseCase: getIt(),
        getNearbyShopsUseCase: getIt(),
      ));

  // Features (Retailer Dashboard)
  getIt.registerLazySingleton<RetailerDashboardRemoteDataSource>(
      () => RetailerDashboardRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<RetailerDashboardRepository>(
      () => RetailerDashboardRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton(() => GetMyShopUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateShopUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateShopUseCase(getIt()));
  getIt.registerLazySingleton(() => GetShopAnalyticsUseCase(getIt()));
  getIt.registerFactory(() => RetailerDashboardBloc(
        getMyShopUseCase: getIt(),
        createShopUseCase: getIt(),
        updateShopUseCase: getIt(),
        getShopAnalyticsUseCase: getIt(),
      ));

  // Features (Influencer)
  getIt.registerLazySingleton<InfluencerRemoteDataSource>(
      () => InfluencerRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<InfluencerAnalyticsRemoteDataSource>(
      () => InfluencerAnalyticsRemoteDataSource(getIt()));
  getIt.registerLazySingleton<InfluencerRepository>(
      () => InfluencerRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<InfluencerAnalyticsRepository>(
      () => InfluencerAnalyticsRepositoryImpl(remoteDataSource: getIt()));
  
  getIt.registerLazySingleton(() => GetInfluencerProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateInfluencerProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => GetEligibleCampaignsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetMyBidsUseCase(getIt()));
  getIt.registerLazySingleton(() => SubmitBidUseCase(getIt()));
  getIt.registerLazySingleton(() => WithdrawBidUseCase(getIt()));
  getIt.registerLazySingleton(() => GetInfluencerAnalyticsUseCase(getIt()));

  getIt.registerFactory(() => InfluencerBloc(
        getProfile: getIt(),
        updateProfile: getIt(),
        getCampaigns: getIt(),
        getMyBids: getIt(),
        submitBid: getIt(),
        withdrawBid: getIt(),
        getAnalytics: getIt(),
      ));

  // Features (Negotiation)
  getIt.registerLazySingleton<NegotiationRemoteDataSource>(
      () => NegotiationRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<NegotiationRepository>(
      () => NegotiationRepositoryImpl(remoteDataSource: getIt()));
      
  // Customer Use Cases
  getIt.registerLazySingleton(() => StartNegotiationUseCase(getIt()));
  getIt.registerLazySingleton(() => GetMyNegotiationsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetNegotiationDetailUseCase(getIt()));
  getIt.registerLazySingleton(() => CounterOfferUseCase(getIt()));
  getIt.registerLazySingleton(() => AcceptDealUseCase(getIt()));
  getIt.registerLazySingleton(() => RejectDealUseCase(getIt()));

  // Shopkeeper Use Cases
  getIt.registerLazySingleton(() => GetShopNegotiationsUseCase(getIt()));
  getIt.registerLazySingleton(() => ShopkeeperCounterUseCase(getIt()));
  getIt.registerLazySingleton(() => ShopkeeperAcceptUseCase(getIt()));
  getIt.registerLazySingleton(() => ShopkeeperRejectUseCase(getIt()));

  // Features (Saved)
  getIt.registerLazySingleton<SavedRemoteDataSource>(
      () => SavedRemoteDataSourceImpl(apiClient: getIt()));
  getIt.registerLazySingleton<SavedRepository>(
      () => SavedRepositoryImpl(remoteDataSource: getIt()));
  
  getIt.registerLazySingleton(() => GetSavedProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => SaveProductUseCase(getIt()));
  getIt.registerLazySingleton(() => RemoveSavedProductUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSavedShopsUseCase(getIt()));
  getIt.registerLazySingleton(() => SaveShopUseCase(getIt()));
  getIt.registerLazySingleton(() => RemoveSavedShopUseCase(getIt()));

  getIt.registerFactory(() => SavedBloc(
        getSavedProducts: getIt(),
        saveProduct: getIt(),
        removeSavedProduct: getIt(),
        getSavedShops: getIt(),
        saveShop: getIt(),
        removeSavedShop: getIt(),
      ));

  // Features (Addresses)
  getIt.registerLazySingleton<AddressesRemoteDataSource>(
      () => AddressesRemoteDataSourceImpl(apiClient: getIt()));
  getIt.registerLazySingleton<AddressesRepository>(
      () => AddressesRepositoryImpl(remoteDataSource: getIt()));
  
  getIt.registerLazySingleton(() => GetAddressesUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateAddressUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateAddressUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteAddressUseCase(getIt()));

  getIt.registerFactory(() => AddressesBloc(
        getAddresses: getIt(),
        createAddress: getIt(),
        updateAddress: getIt(),
        deleteAddress: getIt(),
      ));

  getIt.registerFactory(() => NegotiationBloc(
        startNegotiation: getIt(),
        getMyNegotiations: getIt(),
        getNegotiationDetail: getIt(),
        counterOffer: getIt(),
        acceptDeal: getIt(),
        rejectDeal: getIt(),
      ));

  getIt.registerFactory(() => RetailerNegotiationBloc(
        getShopNegotiations: getIt(),
        shopkeeperCounter: getIt(),
        shopkeeperAccept: getIt(),
        shopkeeperReject: getIt(),
      ));

  // Features (Retailer Campaigns)
  getIt.registerLazySingleton<RetailerCampaignRemoteDataSource>(
      () => RetailerCampaignRemoteDataSourceImpl(apiClient: getIt()));
  getIt.registerLazySingleton<RetailerCampaignRepository>(
      () => RetailerCampaignRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton(() => CreateCampaignUseCase(getIt()));
  getIt.registerLazySingleton(() => GetMyCampaignsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCampaignBidsUseCase(getIt()));
  getIt.registerLazySingleton(() => AcceptBidUseCase(getIt()));
  getIt.registerLazySingleton(() => CounterBidUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateCampaignUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteCampaignUseCase(getIt()));
  getIt.registerFactory(() => RetailerCampaignBloc(
        createCampaign: getIt(),
        getMyCampaigns: getIt(),
        getCampaignBids: getIt(),
        acceptBid: getIt(),
        counterBid: getIt(),
        updateCampaign: getIt(),
        deleteCampaign: getIt(),
      ));

  // Search Module
  getIt.registerLazySingleton<SearchRemoteDataSource>(
      () => SearchRemoteDataSourceImpl(apiClient: getIt()));
  getIt.registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton(() => GlobalSearchUseCase(getIt()));
  getIt.registerFactory(() => SearchBloc(globalSearch: getIt()));

  // Notifications Module
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(apiClient: getIt()));
  getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(remoteDataSource: getIt()));

  
  // Cloudinary Service
  getIt.registerLazySingleton(() => CloudinaryService(apiClient: getIt()));
  getIt.registerLazySingleton(() => GetMyNotificationsUseCase(getIt()));
  getIt.registerLazySingleton(() => MarkAllAsReadUseCase(getIt()));
  getIt.registerFactory(() => NotificationBloc(
    getMyNotifications: getIt(),
    markAllAsRead: getIt(),
  ));

  // Promotions Module
  getIt.registerLazySingleton<PromotionRepository>(
      () => PromotionRepositoryImpl(apiClient: getIt()));
  getIt.registerFactory(() => PromotionBloc(repository: getIt()));

  // Events
  getIt.registerLazySingleton<EventRemoteDataSource>(() => EventRemoteDataSourceImpl(dio: getIt()));
  getIt.registerFactory(() => EventBloc(remoteDataSource: getIt()));
}
