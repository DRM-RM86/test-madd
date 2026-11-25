import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

abstract class CharacterImageStore {
  Future<String?> save({
    required String phone,
    required int id,
    required String url,
  });

  Future<void> delete(String? path);
}

class CharacterImageStoreImpl implements CharacterImageStore {
  CharacterImageStoreImpl(this.dio);

  final Dio dio;

  @override
  Future<String?> save({
    required String phone,
    required int id,
    required String url,
  }) async {
    if (url.isEmpty) return null;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final folder = Directory('${directory.path}/saved/$phone');
      await folder.create(recursive: true);
      final file = File('${folder.path}/$id.jpg');
      await dio.download(url, file.path);
      return file.path;
    } on Object {
      return null;
    }
  }

  @override
  Future<void> delete(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
