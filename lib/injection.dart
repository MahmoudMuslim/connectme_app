import 'package:get_it/get_it.dart';

import 'data/repositories/donation_repository_impl.dart';
import 'data/repositories/post_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/donation_repository.dart';
import 'domain/repositories/post_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/usecases/create_donation.dart';
import 'domain/usecases/create_post.dart';
import 'domain/usecases/delete_post.dart';
import 'domain/usecases/get_community_members.dart';
import 'domain/usecases/get_device_info.dart';
import 'domain/usecases/get_donations.dart';
import 'domain/usecases/get_posts.dart';
import 'domain/usecases/restore_session.dart';
import 'domain/usecases/send_password_reset.dart';
import 'domain/usecases/sign_in.dart';
import 'domain/usecases/sign_out.dart';
import 'domain/usecases/sign_up.dart';
import 'domain/usecases/update_display_name.dart';
import 'domain/usecases/update_profile_photo.dart';
import 'domain/usecases/verify_biometrics.dart';
import 'domain/usecases/watch_auth_state.dart';
import 'presentation/blocs/auth/auth_cubit.dart';
import 'presentation/blocs/donation/donation_cubit.dart';
import 'presentation/blocs/post/post_cubit.dart';
import 'presentation/blocs/profile/profile_cubit.dart';
import 'services/auth_service.dart';
import 'services/biometric_service.dart';
import 'services/device_info_service.dart';
import 'services/firestore_service.dart';
import 'services/image_picker_service.dart';
import 'services/payment/demo_payment_gateway.dart';
import 'services/payment/payment_gateway.dart';

/// The service locator.
///
/// Requirement 5: "Register all repositories and use cases in a GetIt DI
/// container in a dedicated injection.dart file."
///
/// Everything the app needs is resolved from here, which is what allows every
/// cubit to be unit tested with fakes — none of them ever calls `GetIt.find`.
final GetIt getIt = GetIt.instance;

/// Builds the whole object graph.
///
/// Must be awaited **before** `runApp` because Firebase initialization is async.
Future<GetIt> registerDependencies() async {
  if (getIt.isRegistered<FirestoreService>()) {
    return getIt;
  }

  // ------------------------------------------------------- Infrastructure
  // SINGLETON PATTERN: the Firestore service is registered as a singleton and
  // also published through `FirestoreService.instance` so data sources can
  // reach it without depending on GetIt. Initialization is awaited because
  // `Firebase.initializeApp` is asynchronous on every platform.
  final FirestoreService firestoreService = await FirestoreService.initialize();
  getIt.registerSingleton<FirestoreService>(firestoreService);

  // Guarded like the platform capabilities below: a widget test can publish a
  // fake AuthService before calling this function and still receive the rest of
  // the graph, because the real one would otherwise hit FirebaseAuth in the VM.
  final AuthService authService;
  if (getIt.isRegistered<AuthService>()) {
    authService = getIt<AuthService>();
  } else {
    authService = AuthService.create(firestoreService: firestoreService);
    AuthService.registerInstance(authService);
    getIt.registerSingleton<AuthService>(authService);
  }

  final BiometricService biometricService = BiometricService.instance;
  BiometricService.registerInstance(biometricService);
  getIt.registerSingleton<BiometricService>(biometricService);

  final DeviceInfoService deviceInfoService = DeviceInfoService.instance;
  DeviceInfoService.registerInstance(deviceInfoService);
  getIt.registerSingleton<DeviceInfoService>(deviceInfoService);

  final ImagePickerService imagePickerService = ImagePickerService.instance;
  ImagePickerService.registerInstance(imagePickerService);
  getIt.registerSingleton<ImagePickerService>(imagePickerService);

  // SOLID: only the concrete gateway is chosen here. Swap this single line for
  // a Stripe implementation and every use case keeps working.
  final PaymentGateway paymentGateway = DemoPaymentGateway();
  getIt.registerSingleton<PaymentGateway>(paymentGateway);

  // ------------------------------------------------------------ Repositories
  // Test seam: a widget test may pre-register a repository backed by the local
  // data source so the feed can be driven without a live Firestore.
  final PostRepositoryImpl postRepository;
  if (getIt.isRegistered<PostRepositoryImpl>()) {
    postRepository = getIt<PostRepositoryImpl>();
  } else {
    postRepository = await PostRepositoryImpl.create(
      firestoreService: firestoreService,
    );
    getIt.registerSingleton<PostRepositoryImpl>(postRepository);
  }
  // Registered under both keys: the cubit needs the concrete type to read the
  // "which data source?" metadata, while the use cases depend on the interface.
  if (!getIt.isRegistered<PostRepository>()) {
    getIt.registerSingleton<PostRepository>(postRepository);
  }

  final UserRepository userRepository = UserRepositoryImpl(
    authService: authService,
    firestoreService: firestoreService,
  );
  getIt.registerSingleton<UserRepository>(userRepository);

  final DonationRepository donationRepository = DonationRepositoryImpl(
    gateway: paymentGateway,
    firestoreService: firestoreService,
  );
  getIt.registerSingleton<DonationRepository>(donationRepository);

  // -------------------------------------------------------------- Use cases
  // Every use case is registered as a lazy singleton so it can also be resolved
  // directly from a widget test.
  getIt
    ..registerLazySingleton<GetPosts>(() => GetPosts(getIt<PostRepository>()))
    ..registerLazySingleton<CreatePost>(
      () => CreatePost(getIt<PostRepository>()),
    )
    ..registerLazySingleton<DeletePost>(
      () => DeletePost(getIt<PostRepository>()),
    )
    ..registerLazySingleton<SignIn>(() => SignIn(getIt<UserRepository>()))
    ..registerLazySingleton<SignUp>(() => SignUp(getIt<UserRepository>()))
    ..registerLazySingleton<SendPasswordReset>(
      () => SendPasswordReset(getIt<UserRepository>()),
    )
    ..registerLazySingleton<SignOut>(() => SignOut(getIt<UserRepository>()))
    ..registerLazySingleton<RestoreSession>(
      () => RestoreSession(getIt<UserRepository>()),
    )
    ..registerLazySingleton<WatchAuthState>(
      () => WatchAuthState(getIt<UserRepository>()),
    )
    ..registerLazySingleton<UpdateProfilePhoto>(
      () => UpdateProfilePhoto(getIt<UserRepository>()),
    )
    ..registerLazySingleton<UpdateDisplayName>(
      () => UpdateDisplayName(getIt<UserRepository>()),
    )
    ..registerLazySingleton<GetCommunityMembers>(
      () => GetCommunityMembers(getIt<UserRepository>()),
    )
    ..registerLazySingleton<CreateDonation>(
      () => CreateDonation(getIt<DonationRepository>()),
    )
    ..registerLazySingleton<GetDonations>(
      () => GetDonations(getIt<DonationRepository>()),
    );

  // Platform capabilities are exposed through the *domain contracts* so the
  // use cases stay platform agnostic (Dependency Inversion).
  //
  // Every registration is guarded by `isRegistered` so a widget test can publish
  // its own fake **before** calling this function and still receive the rest of
  // the graph — the standard GetIt testing seam.
  if (!getIt.isRegistered<BiometricRepository>()) {
    getIt.registerLazySingleton<BiometricRepository>(() => biometricService);
  }
  if (!getIt.isRegistered<DeviceInfoRepository>()) {
    getIt.registerLazySingleton<DeviceInfoRepository>(() => deviceInfoService);
  }
  getIt
    ..registerLazySingleton<GetDeviceInfo>(
      () => GetDeviceInfo(getIt<DeviceInfoRepository>()),
    )
    ..registerLazySingleton<VerifyBiometrics>(
      () => VerifyBiometrics(getIt<BiometricRepository>()),
    );

  // ------------------------------------------------------------- Cubit factories
  // Cubits are registered as *factories*: every `BlocProvider` asks GetIt for a
  // fresh instance, which keeps the widget tree free of manual constructors and
  // lets a widget test substitute a cubit backed by fakes.
  getIt
    ..registerFactory<AuthCubit>(
      () => AuthCubit(
        signInUseCase: getIt<SignIn>(),
        signUpUseCase: getIt<SignUp>(),
        sendPasswordResetUseCase: getIt<SendPasswordReset>(),
        signOutUseCase: getIt<SignOut>(),
        restoreSession: getIt<RestoreSession>(),
        watchAuthState: getIt<WatchAuthState>(),
        authService: authService,
      ),
    )
    ..registerFactory<PostCubit>(
      () => PostCubit(
        getPosts: getIt<GetPosts>(),
        createPost: getIt<CreatePost>(),
        deletePost: getIt<DeletePost>(),
        postRepository: getIt<PostRepositoryImpl>(),
      ),
    )
    ..registerFactory<ProfileCubit>(
      () => ProfileCubit(
        getDeviceInfo: getIt<GetDeviceInfo>(),
        updateProfilePhoto: getIt<UpdateProfilePhoto>(),
        updateDisplayName: getIt<UpdateDisplayName>(),
        verifyBiometrics: getIt<VerifyBiometrics>(),
        imagePickerService: imagePickerService,
      ),
    )
    ..registerFactory<DonationCubit>(
      () => DonationCubit(
        createDonation: getIt<CreateDonation>(),
        getDonations: getIt<GetDonations>(),
      ),
    );

  return getIt;
}

/// Releases every registration — used by `flutter test` tear-down.
Future<void> resetDependencies() async {
  await getIt.reset();
  FirestoreService.resetForTesting();
  AuthService.resetForTesting();
}