import 'package:flutter/material.dart';
import 'package:webtoon/models/webtoon_model.dart';
import 'package:webtoon/services/api_service.dart';
import 'package:webtoon/widgets/webtoon_widget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final Future<List<WebtoonModel>> webtoons = ApiService.getTodaysToons();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        title: const Text(
          "Today's Webtoon",
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: FutureBuilder(
        // Future(webtoons)을 정의해주면 알아서 값을 기다려주는 함수
        future: webtoons,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Expanded(child: makeList(snapshot)),
                // Column는 무한한 높이를 가지고, Column은 ListView.separated의 높이를 모르기때문에 Expanded 안써주면 오류남. 높이를 정해줘야함.
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  ListView makeList(AsyncSnapshot<List<WebtoonModel>> snapshot) {
    return ListView.separated(
      // ListView.builder과 seperated는 그냥 ListView보다 더 최적화되어있음.
      // 한 번에 불러오지않아 메모리에 과부하를 주지 않음.
      // LisetViews.sepearated: ListView.builder에 더해 seperatorBuilder라는 필수인자를 하나 더 가짐. 구분자
      itemCount: snapshot.data!.length,
      scrollDirection: Axis.horizontal,
      // ListView 항목들의 총개수. 주어지지 않으면 무한히 항목을 만들게됨.
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      // padding 주게되면 그림자 시작점도 달라짐.
      itemBuilder: (context, index) {
        var webtoon = snapshot.data![index];
        return Webtoon(
          title: webtoon.title,
          thumb: webtoon.thumb,
          id: webtoon.id,
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(width: 20);
      },
    );
  }
}
