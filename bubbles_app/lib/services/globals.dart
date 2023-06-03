import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';

class Globals {
  static final Globals service = Globals._internal();

  Globals._internal();

  final DatabaseService db = GetIt.instance.get<DatabaseService>();
  final CloudStorageService storage = GetIt.instance.get<CloudStorageService>();
  final MediaService media = GetIt.instance.get<MediaService>();
  final NavigationService navigation = GetIt.instance.get<NavigationService>();
  final Logger logger = GetIt.instance.get<Logger>();
}
