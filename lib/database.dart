import 'dart:convert';
import 'dart:typed_data';
import 'package:covid_19/Repository.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FilePersistence implements Repository {
  // 2
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // 3
  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }



  @override
  Future<void> removeImage(String userId, String key) {
    // TODO: implement removeImage
    throw UnimplementedError();
  }

  @override
  Future<void> removeObject(String userId, String key) {
    // TODO: implement removeObject
    throw UnimplementedError();
  }

  @override
  Future<void> removeString(String userId, String key) {
    // TODO: implement removeString
    throw UnimplementedError();
  }



Future<String> getFilename(String userId, String type, String key) async {
  return userId + '/' + type + '/' + key;
}



@override
Future<String> saveImage(String userId, String key, Uint8List image) async {
  // 1
  final filename = await getFilename(userId, 'images', key);
  // 2
  final file = await _localFile(filename);

  // 3
  if (!await file.parent.exists()) await file.parent.create(recursive: true);

  // 4
  await file.writeAsBytes(image);
  return filename;
}



@override
void saveObject(
    String userId, String key, Map object) async {
  final filename = await getFilename(userId, 'objects', key);
  final file = await _localFile(filename);

  if (!await file.parent.exists()) await file.parent.create(recursive: true);

  // 5
  final jsonString = JsonEncoder().convert(object);
  await file.writeAsString(jsonString);
}


  @override
  Future<Map> getObject(String userId, String key) async {
    final filename = await getFilename(userId, 'objects', key);
    final file = await _localFile(filename);

    // 3
    if (await file.exists()) {
      final objectString = await file.readAsString();
      return JsonDecoder().convert(objectString);
    }
    return null;
  }

@override
void saveString(String userId, String key, String value) async {
  final filename = await getFilename(userId, 'strings', key);
  final file = await _localFile(filename);

  if (!await file.parent.exists()) await file.parent.create(recursive: true);

  // 6
  await file.writeAsString(value);
}


  @override
  Future<Uint8List> getImage(String userId, String key) async {
    final filename = await getFilename(userId, 'images', key);
    final file = await _localFile(filename);

    // 1
    if (await file.exists()) return await file.readAsBytes();
    return null;
  }

  @override
  Future<String> getString(String userId, String key) async {
    final filename = await getFilename(userId, 'strings', key);
    final file = await _localFile(filename);

    // 2
    if (await file.exists()) return await file.readAsString();
    return null;
  }






}