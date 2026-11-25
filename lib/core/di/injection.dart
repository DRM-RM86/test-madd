import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:pruebatecnica/core/database/app_database.dart';
import 'package:pruebatecnica/core/notifications/local_notifications.dart';
import 'package:pruebatecnica/features/auth/data/code_generator.dart';
import 'package:pruebatecnica/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pruebatecnica/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pruebatecnica/features/auth/domain/repositories/auth_repository.dart';
import 'package:pruebatecnica/features/auth/domain/usecases/get_session.dart';
import 'package:pruebatecnica/features/auth/domain/usecases/request_verification_code.dart';
import 'package:pruebatecnica/features/auth/domain/usecases/sign_out.dart';
import 'package:pruebatecnica/features/auth/domain/usecases/verify_code.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pruebatecnica/features/characters/data/datasources/character_image_store.dart';
import 'package:pruebatecnica/features/characters/data/datasources/character_local_data_source.dart';
import 'package:pruebatecnica/features/characters/data/datasources/character_remote_data_source.dart';
import 'package:pruebatecnica/features/characters/data/datasources/workspace_store.dart';
import 'package:pruebatecnica/features/characters/data/repositories/character_repository_impl.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character.dart';
import 'package:pruebatecnica/features/characters/domain/repositories/character_repository.dart';
import 'package:pruebatecnica/features/characters/domain/usecases/saved_character_actions.dart';
import 'package:pruebatecnica/features/characters/domain/usecases/search_characters.dart';
import 'package:pruebatecnica/features/characters/presentation/bloc/character_detail_bloc.dart';
import 'package:pruebatecnica/features/characters/presentation/bloc/saved_characters_bloc.dart';
import 'package:pruebatecnica/features/characters/presentation/bloc/search_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> init({OtpNotifier? otpNotifier}) async {
  final preferences = await SharedPreferences.getInstance();
  final OtpNotifier notifications;
  if (otpNotifier != null) {
    notifications = otpNotifier;
  } else {
    final plugin = LocalNotifications(FlutterLocalNotificationsPlugin());
    await plugin.initialize();
    notifications = plugin;
  }

  getIt
    ..registerSingleton<SharedPreferences>(preferences)
    ..registerSingleton<OtpNotifier>(notifications)
    ..registerLazySingleton<CodeGenerator>(FourDigitCodeGenerator.new)
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () =>
          AuthRepositoryImpl(local: getIt(), notifier: getIt(), codes: getIt()),
    )
    ..registerLazySingleton(() => RequestVerificationCode(getIt()))
    ..registerLazySingleton(() => VerifyCode(getIt()))
    ..registerLazySingleton(() => GetSession(getIt()))
    ..registerLazySingleton(() => SignOut(getIt()))
    ..registerFactory(
      () => AuthBloc(
        requestVerificationCode: getIt(),
        verifyCode: getIt(),
        getSession: getIt(),
        signOut: getIt(),
      ),
    )
    ..registerLazySingleton(
      () => Dio(
        BaseOptions(
          baseUrl: 'https://rickandmortyapi.com/api',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ),
    )
    ..registerLazySingleton(AppDatabase.new)
    ..registerLazySingleton(() => WorkspaceStore(getIt()))
    ..registerLazySingleton<CharacterRemoteDataSource>(
      () => CharacterRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<CharacterLocalDataSource>(
      () => CharacterLocalDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<CharacterImageStore>(
      () => CharacterImageStoreImpl(getIt()),
    )
    ..registerLazySingleton<CharacterRepository>(
      () => CharacterRepositoryImpl(
        remote: getIt(),
        local: getIt(),
        images: getIt(),
      ),
    )
    ..registerLazySingleton(() => SearchCharacters(getIt()))
    ..registerLazySingleton(() => GetSavedCharacters(getIt()))
    ..registerLazySingleton(() => IsCharacterSaved(getIt()))
    ..registerLazySingleton(() => GetSavedIds(getIt()))
    ..registerLazySingleton(() => LoadCharacterProfile(getIt()))
    ..registerLazySingleton(() => SaveCharacter(getIt()))
    ..registerLazySingleton(() => RemoveSavedCharacter(getIt()))
    ..registerFactoryParam<SearchBloc, String, void>(
      (phone, _) => SearchBloc(
        phone: phone,
        searchCharacters: getIt(),
        getSavedIds: getIt(),
        workspace: getIt(),
      ),
    )
    ..registerFactoryParam<SavedCharactersBloc, String, void>(
      (phone, _) =>
          SavedCharactersBloc(phone: phone, getSavedCharacters: getIt()),
    )
    ..registerFactoryParam<CharacterDetailBloc, Character, String>(
      (character, phone) => CharacterDetailBloc(
        phone: phone,
        character: character,
        isCharacterSaved: getIt(),
        loadCharacterProfile: getIt(),
        saveCharacter: getIt(),
        removeSavedCharacter: getIt(),
      ),
    );
}
