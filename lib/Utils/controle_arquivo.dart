import 'dart:io';

import 'package:path_provider/path_provider.dart';

// Classe criada para facilitar o Controle de Arquivos.
class ControleArquivo {
  // Função para conseguir o diretório do arquivo.
  Future<File> _localFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/IdMusic.txt');
  }

  // Função para pegar as informações do arquivo.
  Future<String> getFile() async {
    final file = await _localFile();
    return await file.readAsString();
  }

  // Função que separa o arquivo em uma lista.
  Future<List<String>> readCounter() async {
    try {
      final file = await _localFile();

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

  // Função para sobrescrever o arquivo.
  Future<File> overWrite(String id) async {
    final file = await _localFile();

    // Write the file
    return file.writeAsString(id, mode: FileMode.write);
  }

  // Função para adicionar no arquivo.
  Future<File> writeAdd(String id) async {
    final file = await _localFile();

    // Write the file
    return file.writeAsString('$id-/-', mode: FileMode.append);
  }

  // Função para apagar os conteúdos do arquivo.
  Future<File> delete() async {
    final file = await _localFile();

    return file.writeAsString('', mode: FileMode.write);
  }

  // Função para atualizar o arquivo.
  Future<File> update(String removeID) async {
    final file = await _localFile();

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
