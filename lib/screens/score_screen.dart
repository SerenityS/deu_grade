import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../utilities/deu_api.dart';

class ScoreListScreen extends StatefulWidget {
  @override
  _ScoreListScreenState createState() => _ScoreListScreenState();
}

class _ScoreListScreenState extends State<ScoreListScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 2000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '금학기 성적 조회',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black),
        ),
      ),
      body: FutureBuilder(
        future: DEUApi().getGradeList(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == false) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 15),
              ),
            );
          } else {
            if (snapshot.data == 0) {
              return const Center(
                child: Text("성적 정보가 존재하지 않습니다."),
              );
            } else {
              return SmartRefresher(
                enablePullDown: true,
                header: const ClassicHeader(
                  completeText: '새로고침 완료',
                  idleText: '아래로 당겨서 새로고침',
                  refreshingText: '새로고침 중...',
                  releaseText: '새로고침',
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView.separated(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.white,
                      child: ExpansionTile(
                        title: Text(
                          '${snapshot.data[index][0]} - ${snapshot.data[index][2][4].text}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.white,
                        children: [
                          ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: snapshot.data[index][1].length,
                            itemBuilder: (context, idx) {
                              return ListTile(
                                title: Text(
                                    '${snapshot.data[index][1][idx].text} : ${snapshot.data[index][2][idx].text}'),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const Divider(
                                height: 1,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(
                      height: 1,
                    );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}
