class SearchModel {
  List<String>? id;
  List<String>? title;
  List<String>? author;
  List<String>? viewCount;
  List<DateTime>? uploadDate;
  List<String>? uploadDateRaw;
  List<Duration>? duration;

  SearchModel({
    this.id,
    this.title,
    this.author,
    this.viewCount,
    this.uploadDate,
    this.uploadDateRaw,
    this.duration,
  });
}
