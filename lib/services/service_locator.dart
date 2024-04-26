import 'package:get_it/get_it.dart';
import 'package:poem/business_logic/view_models/edit_view_model.dart';
import 'package:poem/business_logic/view_models/home_view_model.dart';
import 'package:poem/business_logic/view_models/learning_view_model.dart';
import 'package:poem/business_logic/view_models/upload_view_model.dart';
import 'package:poem/services/poems/poem_service.dart';
import 'package:poem/services/sound/sound_service.dart';
import 'package:poem/services/storage/store_service.dart';
import 'package:poem/services/storage/store_service_hive.dart';
import 'package:poem/services/text/text_service.dart';

GetIt serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // services
  serviceLocator.registerLazySingleton<StoreService>(() => StoreServiceHive());
  serviceLocator.registerLazySingleton<TextsService>(() => TextsService());
  serviceLocator.registerLazySingleton<SoundService>(() => SoundService());
  serviceLocator.registerLazySingleton<PoemService>(() => PoemService());

  // view models
  serviceLocator.registerFactory<HomeViewModel>(() => HomeViewModel());
  serviceLocator.registerFactory<LearningViewModel>(() => LearningViewModel());
  serviceLocator.registerFactory<UploadViewModel>(() => UploadViewModel());
  serviceLocator.registerFactory<EditViewModel>(() => EditViewModel());

  //init
  await serviceLocator<StoreService>().initDb();
  await serviceLocator<SoundService>().init();
}
