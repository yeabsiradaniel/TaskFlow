import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/datasources/local/task_local_datasource.dart';
import '../../data/datasources/local/category_local_datasource.dart';
import '../../data/datasources/remote/task_remote_datasource.dart';
import '../../data/datasources/remote/category_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../notifications/notification_service.dart';
import '../../presentation/blocs/task/task_bloc.dart';
import '../../presentation/blocs/auth/auth_cubit.dart';
import '../../presentation/blocs/category/category_cubit.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Firebase & Auth
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => GoogleSignIn.instance);

  // Notifications
  sl.registerLazySingleton(() => NotificationService());

  // Datasources
  sl.registerLazySingleton(() => TaskLocalDatasource());
  sl.registerLazySingleton(() => CategoryLocalDatasource());
  sl.registerLazySingleton(() => TaskRemoteDatasource(sl()));
  sl.registerLazySingleton(() => CategoryRemoteDatasource(sl()));

  // Repositories
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl(), sl(), sl()),
  );

  // BLoCs
  sl.registerFactory(() => TaskBloc(sl(), sl()));
  sl.registerFactory(() => AuthCubit(sl(), sl()));
  sl.registerFactory(() => CategoryCubit(sl()));
}
