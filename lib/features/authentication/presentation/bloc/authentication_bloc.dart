import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/check_session_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../influencer/data/datasources/influencer_remote_data_source.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final CheckSessionUseCase _checkSessionUseCase;
  final LogoutUseCase _logoutUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  AuthenticationBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required CheckSessionUseCase checkSessionUseCase,
    required LogoutUseCase logoutUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _checkSessionUseCase = checkSessionUseCase,
        _logoutUseCase = logoutUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        super(const AuthenticationInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<GuestLoginRequested>(_onGuestLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckSessionRequested>(_onCheckSessionRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  /// Checks if an influencer's profile is approved before letting them in.
  Future<bool> _isInfluencerApproved() async {
    try {
      final dataSource = getIt<InfluencerRemoteDataSource>();
      final profile = await dataSource.getProfile();
      return profile.verificationStatus == 'APPROVED';
    } catch (_) {
      // If we can't fetch the profile (e.g. newly signed up, profile not yet created),
      // treat as PENDING to be safe.
      return false;
    }
  }

  Future<void> _onCheckSessionRequested(CheckSessionRequested event, Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationLoading());
    final result = await _checkSessionUseCase.execute();
    await result.fold(
      (failure) async => emit(const AuthenticationUnauthenticated()),
      (user) async {
        getIt<PushNotificationService>().initialize();
        // Check influencer verification status on session restore
        if (user.role == 'INFLUENCER') {
          final approved = await _isInfluencerApproved();
          if (!approved) {
            emit(AuthenticationInfluencerPending(user));
            return;
          }
        }
        emit(AuthenticationLoaded(user));
      },
    );
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationLoading());
    final result = await _loginUseCase.execute(event.emailOrPhone, event.password, event.role);
    await result.fold(
      (failure) async => emit(AuthenticationError(failure)),
      (user) async {
        getIt<PushNotificationService>().initialize();
        if (user.role == 'INFLUENCER') {
          final approved = await _isInfluencerApproved();
          if (!approved) {
            emit(AuthenticationInfluencerPending(user));
            return;
          }
        }
        emit(AuthenticationLoaded(user));
      },
    );
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationLoading());
    final result = await _registerUseCase.execute(event.name, event.emailOrPhone, event.password, event.role);
    await result.fold(
      (failure) async => emit(AuthenticationError(failure)),
      (user) async {
        getIt<PushNotificationService>().initialize();
        // New influencer registrations always start as PENDING
        if (user.role.toUpperCase() == 'INFLUENCER') {
          emit(AuthenticationInfluencerPending(user));
          return;
        }
        emit(AuthenticationLoaded(user));
      },
    );
  }

  Future<void> _onGuestLoginRequested(GuestLoginRequested event, Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationLoading());
    await Future.delayed(const Duration(milliseconds: 50));
    emit(const AuthenticationGuest());
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationLoading());
    await _logoutUseCase.execute();
    emit(const AuthenticationUnauthenticated());
  }

  Future<void> _onUpdateProfileRequested(UpdateProfileRequested event, Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationLoading());
    final result = await _updateProfileUseCase.execute(event.name);
    result.fold(
      (failure) => emit(AuthenticationError(failure)),
      (user) => emit(AuthenticationLoaded(user)),
    );
  }
}
