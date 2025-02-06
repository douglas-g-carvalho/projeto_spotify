import 'package:just_audio/just_audio.dart';

// Classe criada com o intuito de ser um molde e facilitar o processo de guardar informações.
// Para ser utilizada posteriormente no SearchPlay.

class SearchModel {
  List<String>? id;
  List<String>? title;
  List<String>? author;
  List<String>? viewCount;
  List<DateTime>? uploadDate;
  List<String>? uploadDateRaw;
  List<String>? duration;
  List<AudioSource>? urlSound;

  SearchModel({
    this.id,
    this.title,
    this.author,
    this.viewCount,
    this.uploadDate,
    this.uploadDateRaw,
    this.duration,
    this.urlSound,
  });
}
