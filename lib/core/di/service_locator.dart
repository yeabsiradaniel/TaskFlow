import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/datasources/local/task_local_datasource.dart';
import '../../data/datasources/local/category_local_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../presentation/blocs/task/task_bloc.dart';
import '../../presentation/blocs/auth/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // Datasources
  sl.registerLazySingleton(() => TaskLocalDatasource());
  sl.registerLazySingleton(() => CategoryLocalDatasource());

  // Repositories
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );

  // BLoCs
  sl.registerFactory(() => TaskBloc(sl()));
  sl.registerFactory(() => AuthCubit(sl()));
}
