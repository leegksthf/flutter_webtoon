class WebtoonEpisodeModel {
  final String id, title, rating, date;

// fromJson: json String을 object로 변환해줌
  WebtoonEpisodeModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        rating = json['rating'],
        date = json['date'];
}
