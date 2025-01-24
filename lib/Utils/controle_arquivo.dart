import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ControleArquivo {
  Future<File> _localFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/$fileName.txt');
  }

  Future<String> getFile(String fileName) async {
    final file = await _localFile(fileName);
    return await file.readAsString();
  }

  Future<List<String>> readCounter(String filename) async {
    try {
      final file = await _localFile(filename);

      // Read the file
      final contents = await file.readAsString();
      final List<String> listContents = contents.split('-/-');
      listContents.removeWhere((value) => value == '');

      return listContents;
    } catch (e) {
      // If encountering an error, return 0
      return [];
    }
  }

  Future<File> overWrite(String filename, String id) async {
    final file = await _localFile(filename);

    // Write the file
    return file.writeAsString(id, mode: FileMode.write);
  }

  Future<File> writeAdd(String filename, String id) async {
    final file = await _localFile(filename);

    // Write the file
    return file.writeAsString('$id-/-', mode: FileMode.append);
  }

  Future<File> delete(String filename) async {
    final file = await _localFile(filename);

    return file.writeAsString('', mode: FileMode.write);
  }

  Future<File> update(String filename, String removeID) async {
    final file = await _localFile(filename);

    String newFile = await file.readAsString();

    List<String> actualList = newFile.split('-/-');

    String newList = '';

    actualList.remove(removeID);
    actualList.remove('');
    for (String value in actualList) {
      newList += '$value-/-';
    }

    return file.writeAsString(newList, mode: FileMode.write);
  }
}
