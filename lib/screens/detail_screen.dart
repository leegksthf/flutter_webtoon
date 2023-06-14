import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webtoon/models/webtoon_detail_model.dart';
import 'package:webtoon/models/webtoon_episode_model.dart';
import 'package:webtoon/services/api_service.dart';
import 'package:webtoon/widgets/episode_widget.dart';

class DetailScreen extends StatefulWidget {
  final String title, thumb, id;

  const DetailScreen(
      {super.key, required this.title, required this.thumb, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoon;
  late Future<List<WebtoonEpisodeModel>> episodes;
  // Futre<WebtoonDetailModel> webtoon = ApiService.getToonById(widget.id);
  // constructor에서 widget이 참조될 수 없기 때문에 위 코드는 오류뜸.

  // stateless에서 위 코드를 써도 오류가 뜨는데,
  // webtoon property를 초기화할 때 다른 prop(id)에 대한 접근이 불가함.

  late SharedPreferences prefs;
  bool isLiked = false;

  Future initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final likedToons = prefs.getStringList('likedToons');
    if (likedToons != null) {
      if (likedToons.contains(widget.id) == true) {
        setState(() {
          isLiked = true;
        });
      }
    } else {
      await prefs.setStringList('likedToons', []);
    }
  }

  Future onHeartTap() async {
    final likedToons = prefs.getStringList('likedToons');
    if (likedToons != null) {
      if (isLiked) {
        likedToons.remove(widget.id);
      } else {
        likedToons.add(widget.id);
      }
      // 휴대폰에 저장
      await prefs.setStringList('likedToons', likedToons);
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getToonById(widget.id);
    episodes = ApiService.getLatestEpisodesById(widget.id);
    // stateful로 바꿔준 이유는 initState가 필요해서임.

    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: onHeartTap,
            icon: Icon(
              isLiked
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_outlined,
            ),
          )
        ],
        title: Text(
          widget.title,
          // widget은 부모한테 가라는 뜻. 별개의 클래스이기때문에 그냥 title로는 접근할 수 없음.
          // State가 속한 StatefulWidget의 data를 받아오기 위해서는 widget을 써줘야함.
          style: const TextStyle(fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
              Center(
                child: Hero(
                  tag: widget.id,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    // clipBehavior은 Container의 모양에서 자식이 범위 밖을 지나면 자동으로 잘라줌
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 15,
                          offset: const Offset(10, 10),
                          color: Colors.black.withOpacity(0.5),
                        )
                      ],
                    ),
                    width: 250,
                    child: Image.network(widget.thumb),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              FutureBuilder(
                future: webtoon,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!.about,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          '${snapshot.data!.genre} / ${snapshot.data!.age}',
                          style: const TextStyle(fontSize: 16),
                        )
                      ],
                    );
                  }
                  return const Text('...');
                },
              ),
              const SizedBox(
                height: 50,
              ),
              FutureBuilder(
                future: episodes,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // ListView는 부모 위젯의 높이에 맞춰서 자신의 높이를 설정한다. 부모의 높이가 지정되지 않으면 에러뜸. 따라서 ListView의 높이를 설정해줘야함.
                    // 1. ListView에 shrinkWrap: true속성을 주거나
                    // 2. ListView를 SizedBox로 감싸서 height를 주거나
                    // 3. 고정된 높이를 주기는 싫고 화면 나머지 높이를 모두 할당해주고싶다면 ListView를 Expanded로 감싸줌
                    return ListView.builder(
                      // ListView 스크롤 막기
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var episode = snapshot.data![index];
                        return Episode(episode: episode, webtoonId: widget.id);
                      },
                    );
                  }
                  return Container();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
