
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Update extends StatefulWidget{
  @override
  _UpdateState createState() {
    return _UpdateState();
  }
}

class _UpdateState extends State<Update>{

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //(1)
    int bno = ModalRoute.of(context)!.settings.arguments as int;
    print(bno);
    // (2) 전달받은 인수 (id)를 자바에게 보내고 응답객체 받기
    // 함수 호출
    bookFindById(bno);
  }

  //불러오기
  Dio dio = Dio();
  Map<String, dynamic> book = {}; // JSON 타입은 key은 무조건 문자열 그래서 String, value은 다양한 자료 타입 이므로 dynamic(동적타입)
  void bookFindById(bno) async {
    try{
      final response = await dio.get("http://localhost:8080/book/view?bno=$bno");
      final data = response.data;
      setState(() {
        book = data;
        // 입력 컨트롤러에 초기값 대입하기
        btitlecontorller.text = data['btitle'];
        bwriterController.text = data['bwriter'];
        bcommentsController.text = data['bcomments'];

      });
      print(book);
    }catch(e){print(e);}
  }




  void bookUpdate() async {
    try{
      final sendData = {
        "bno" : book['bno'],
        "btitle" : btitlecontorller.text,
        "bwriter" : bwriterController.text,
        "bcomments" : bcommentsController.text,
        "bpwd" : bpwdController.text
      };

      final response = await dio.put("http://localhost:8080/book" , data: sendData);
      final data = response.data;
      if(data != false){
        //Navigator.pop(context); 뒤로가기
        Navigator.pushNamed(context, "/"); //home으로 가기
      }
    }catch(e){print(e);}
  }




  final TextEditingController btitlecontorller = TextEditingController();
  final TextEditingController bwriterController = TextEditingController();
  final TextEditingController bcommentsController = TextEditingController();
  final TextEditingController bpwdController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("수정화면"),),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20,),
            TextField(controller: btitlecontorller,decoration: InputDecoration(labelText: "제목"),
              maxLength: 30,
            ),

            SizedBox(height: 20,),
            TextField(controller: bwriterController,decoration: InputDecoration(labelText: "작가"),
              maxLength: 30,
            ),

            SizedBox(height: 20,),
            TextField(controller: bcommentsController,decoration: InputDecoration(labelText: "코멘트"),
              maxLength: 30,
            ),

            SizedBox(height: 20,),
            TextField(controller: bpwdController,decoration: InputDecoration(labelText: "비밀번호"),
              maxLength: 30,
            ),

            OutlinedButton(onPressed: bookUpdate, child: Text("수정하기"))

          ],
        ),
      ),
    );
  }
}