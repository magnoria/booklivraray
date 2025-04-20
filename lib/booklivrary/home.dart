
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget{
  @override
  _HomeState createState() {
    return _HomeState();
  }
}


class _HomeState extends State<Home> {


  // 자바 통신후 findAll 가져오는것
  Dio dio = Dio();
  List<dynamic> bookList = [];
  void bookFindAll() async {
    try{
      final response = await dio.get("http://localhost:8080/book");
      print(response);
      final data = response.data;
      print(data);
      setState(() {
        bookList = data;
      });
    }catch(e){print(e);}
  }

  @override
  void initState() {
    super.initState();
    bookFindAll();
  }

  TextEditingController bpwcontroller = TextEditingController();

  //삭제이벤트 함수
  void bookDelete(book) async {

    try{
      final sendData = {
        "bno" : book['bno'],
        "bpwd" : bpwcontroller.text
      };
      final response = await dio.post("http://localhost:8080/book/delete" , data: sendData);
      final data = response.data;
      if(data == true) Navigator.pushNamed(context, "/");
    }catch(e) {print(e);}
  }



  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text("메인페이지"),),
        body: Center(
          child: Column(
            children: [
              TextButton(onPressed: () => {Navigator.pushNamed(context, "/write")}, child: Text("도서추가"),
              ),
              SizedBox(height: 10),

              Expanded(
                  child: ListView(
                    children:
                        bookList.map((book) {
                          return Card(
                            child: ListTile(
                              title: Text(book['btitle']), // 책 제목
                              subtitle: Column(
                                children: [
                                  Text("작가 : ${book['bwriter']}"),
                                  Text("책내용 : ${book['bcomments']}"),
                                ],
                              ),

                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(onPressed: ()=>{Navigator.pushNamed(context, "/update" ,arguments: book['bno'])}, icon: Icon(Icons.edit)),
                                  IconButton(onPressed: ()=>{Navigator.pushNamed(context, "/detail",arguments: book['bno'])}, icon: Icon(Icons.info)),

                                  IconButton(onPressed: (){
                                    showDialog(context: context, builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("삭제 확인"),
                                        content: Text("${book['btitle']}을(를) 삭제하시겠습니까?"),
                                        actions: <Widget>[
                                          TextButton(child: Text("취소"),
                                          onPressed: (){
                                            Navigator.of(context).pop(); //다이얼로그 닫기
                                          },
                                          ),TextField(controller: bpwcontroller,),
                                          TextButton(child: Text("삭제"),

                                            onPressed: () {
                                            bookDelete(book);
                                            Navigator.of(context).pop();}
                                          )
                                        ],
                                      );
                                    },
                                    );

                                  }, icon: Icon(Icons.delete_forever)),
                                ],
                              ),
                            ),
                          );
                        }).toList(), //map 결과를 toList()함수를 이용하여 List 타입으로 변환

              )),

            ],
          ),
        ),
      );
  }
}

