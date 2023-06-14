import 'package:flutter/material.dart';
import 'package:webtoon/screens/detail_screen.dart';

class Webtoon extends StatelessWidget {
  final String title, thumb, id;

  const Webtoon({
    super.key,
    required this.title,
    required this.thumb,
    required this.id,
    // webtoon 자체를 받아올 수도 있고, 쪼개서 받아올 수도 있음. url은 안받아오니까 쪼개서 받아옴.
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return DetailScreen(title: title, thumb: thumb, id: id);
              // Navigator.push는 StatelessWidget을 원하지 않음.
              // MaterialPageRoute는 StatelessWidget을 Route로 감싸서 다른 스크린처럼 보이게 만들어줌.
              // builder는 route를 만드는 함수.
            },
            fullscreenDialog: true,
          ),
        );
      },
      child: Column(
        children: [
          Hero(
            tag: id,
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
              child: Image.network(thumb),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 22),
          ),
        ],
      ),
    );
  }
}
