

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';


class Write extends StatefulWidget{
    @override
    State<StatefulWidget> createState() {
      return _WriteState();
    }
}

class _WriteState extends State<Write>{

  final TextEditingController btitlecontorller = TextEditingController();
  final TextEditingController bwriterController = TextEditingController();
  final TextEditingController bcommentsController = TextEditingController();
  final TextEditingController bpwdController = TextEditingController();

  Dio dio = Dio();
  void bookSave() async{
    try{
      final sendData = {
        "btitle" : btitlecontorller.text,
        "bwriter" : bwriterController.text,
        "bcomments" : bcommentsController.text,
        "bpwd" : bpwdController.text
      };
      final reponse = await dio.post("http://localhost:8080/book" , data: sendData);
      final data = reponse.data;
      if(data == true) {
        Navigator.pushNamed(context, "/");
      }

    }catch(e){print('e');}
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("책등록화면")),
      body: Center(
        child: Column(
          children: [

            Text("책등록"),
            SizedBox(height: 20,),
            TextField(
              controller: btitlecontorller,
              decoration: InputDecoration(labelText: "책제목"),
              maxLength: 20,
            ),

            SizedBox(height: 20,),
            TextField(
              controller: bwriterController,
              decoration: InputDecoration(labelText: "작가"),
              maxLength: 20,
            ),

            SizedBox(height: 20,),
            TextField(
              controller: bcommentsController,
              decoration: InputDecoration(labelText: "책 코멘트"),
              maxLength: 20,
            ),

            TextField(
              controller: bpwdController,
              decoration: InputDecoration(labelText: "비밀번호(삭제 및 변경시사용됩니다.)"),
              maxLength: 20,
            ),

            SizedBox(height: 20,),
            OutlinedButton(onPressed: bookSave, child: Text("등록하기"))

          ],
        ),
      ),
    );
  }
}

