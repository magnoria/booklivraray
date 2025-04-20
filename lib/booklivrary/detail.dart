
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Detail extends StatefulWidget {
  const Detail({super.key});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  int? bno;
  Dio dio = Dio();
  Map<String, dynamic> book = {};
  List<dynamic> reviewList = [];
  TextEditingController rnameController = TextEditingController();
  TextEditingController rcontentsController = TextEditingController();
  TextEditingController rpwdController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bno = ModalRoute.of(context)!.settings.arguments as int;
    if (bno != null) {
      bookFindById(bno!);
      reviewFindById(bno!);
    }
  }

  Future<void> bookFindById(int bno) async {
    try {
      final response = await dio.get("http://localhost:8080/book/view?bno=$bno");
      final data = response.data;
      setState(() {
        book = data ?? {};
      });
      print('Book Data: $book');
    } catch (e) {
      print('Error fetching book details: $e');
    }
  }

  Future<void> reviewFindById(int bno) async {
    try {
      final response = await dio.get("http://localhost:8080/review?bno=$bno");
      final data = response.data;
      setState(() {
        if (data is List) {
          reviewList = data;
        } else {
          reviewList = [];
          print("Error: Unexpected review data format - $data");
        }
        print('Review List: $reviewList');
      });
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  Future<void> reviewUpdate() async {
    if (bno == null) return;
    try {
      final sendData = {
        "bno": bno,
        "rname": rnameController.text,
        "rcontents": rcontentsController.text,
        "rpwd": rpwdController.text,
      };
      final response = await dio.post("http://localhost:8080/review", data: sendData);
      final data = response.data;
      if (data == true || data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰가 등록되었습니다.')),
        );
        reviewFindById(bno!);
        rnameController.clear();
        rcontentsController.clear();
        rpwdController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰 등록에 실패했습니다.')),
        );
      }
    } catch (e) {
      print('Error submitting review: $e');
    }
  }

  Future<void> reviewDelete(int? rno, String password) async {
    if (bno == null || rno == null) return;
    try {
      final sendData = {
        "rno": rno,
        "rpwd": password,
      };
      final response = await dio.post("http://localhost:8080/review/delete", data: sendData);
      final data = response.data;
      if (data == true || data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰가 삭제되었습니다.')),
        );
        reviewFindById(bno!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰 삭제에 실패했습니다. 비밀번호를 확인해주세요.')),
        );
      }
    } catch (e) {
      print('Error deleting review: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${book['btitle'] ?? '로딩 중...'} ",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("제목 : ${book['btitle'] ?? '로딩 중...'}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("작가 : ${book['bwriter'] ?? '로딩 중...'}"),
            const SizedBox(height: 8),
            Text("설명 : ${book['bcomments'] ?? '로딩 중...'}"),
            const SizedBox(height: 16),
            const Text("리뷰 목록", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            reviewList.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("작성된 리뷰가 없습니다."),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviewList.length,
              itemBuilder: (context, index) {
                final review = reviewList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "닉네임 : ${review['rname'] ?? '내용 없음'}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text("추천사 : ${review['rcontents'] ?? '내용 없음'}"),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                final deletePwdController = TextEditingController();
                                return AlertDialog(
                                  title: const Text("삭제 확인"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${review['rname'] ?? ''}, ${review['rcontents'] ?? ''}을(를) 삭제하시겠습니까?",
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: deletePwdController,
                                        obscureText: true,
                                        decoration:
                                        const InputDecoration(labelText: '비밀번호'),
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text("취소"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("삭제"),
                                      onPressed: () {
                                        reviewDelete(review['rno'], deletePwdController.text);
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text("새로운 리뷰 작성", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: rnameController,
              decoration: const InputDecoration(
                labelText: '닉네임',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: rcontentsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '추천사',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: rpwdController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: reviewUpdate,
              child: const Text('리뷰 등록'),
            ),
          ],
        ),
      ),
    );
  }
}