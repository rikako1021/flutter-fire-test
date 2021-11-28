import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fire/model/account.dart';
import 'package:flutter_fire/utils/authentication.dart';
import 'package:flutter_fire/utils/firestore/users.dart';
import 'package:flutter_fire/utils/function_utils.dart';
import 'package:flutter_fire/utils/widget_utils.dart';
import 'package:flutter_fire/view/start_up/login_page.dart';
import 'package:image_picker/image_picker.dart';


class EditAccountPage extends StatefulWidget {
  const EditAccountPage({Key? key}) : super(key: key);

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  Account myAccount = Authentication.myAccount!;
  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfIntroductionController = TextEditingController();
  File? image;

  ImageProvider getImage() {
    if(image == null) {
      return NetworkImage(myAccount.imagePath);
    } else {
      return FileImage(image!);
    }
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: myAccount.name);
    userIdController = TextEditingController(text: myAccount.userId);
    selfIntroductionController = TextEditingController(text: myAccount.selfIntroduction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.createAppBar('登録情報編集'),
      body: SingleChildScrollView(
    child: Container(
    width: double.infinity,
      child: Column( // 登録情報記入欄
        children: [
          SizedBox(height: 30),
          GestureDetector(
            onTap: () async{
              var result = await FunctionUtils.getImageFromGallery();
              if (result != null) {
                setState(() {
                  image = File(result.path);
                });
              }
            },
            child: CircleAvatar(
              foregroundImage: getImage(), //imageがnullの場合は非表示で、そうでない場合はimageを表示
              radius: 40,
              child: Icon(Icons.add),
            ),
          ),
          Container(
            width: 300,
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'なまえ'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Container(
              width: 300,
              child: TextField(
                controller: userIdController,
                decoration: InputDecoration(hintText: 'ID'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: Container(
              width: 300,
              child: TextField(
                controller: selfIntroductionController,
                decoration: InputDecoration(hintText: '自己紹介'),
              ),
            ),
          ),
          SizedBox(height: 50),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.orange,
              padding: EdgeInsets.symmetric(horizontal:30, vertical: 15),
            ),
            onPressed: () async {
              if (nameController.text.isNotEmpty
                  && userIdController.text.isNotEmpty
                  && selfIntroductionController.text.isNotEmpty
              ) {
                String imagePath = '';
                if(image == null) {
                  imagePath = myAccount.imagePath;
                } else {
                  var result = FunctionUtils.uploadImage(myAccount.id, image!);
                }
                Account updateAccount = Account(
                  id: myAccount.id,
                  name: nameController.text,
                  userId: userIdController.text,
                  selfIntroduction: selfIntroductionController.text,
                  imagePath: imagePath
                );
                Authentication.myAccount = updateAccount; //更新した内容を反映
                var result = await UserFirestore.updateUser(updateAccount);
                if(result == true) {
                  Navigator.pop(context, true);
                }
              }
            },
                child: Text('更新', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 50),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(horizontal:20, vertical: 15),
              ),
              onPressed: () {
                Authentication.signOut();
                while(Navigator.canPop(context)) { //popできる状態ならする
                  Navigator.pop(context);
                }
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()
                ));
              },
              child: Text('ログアウト')
          ),
          SizedBox(height: 100),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                padding: EdgeInsets.symmetric(horizontal:20, vertical: 15),
              ),
              onPressed: () {
                UserFirestore.deleteUser(myAccount.id);
                Authentication.deleteAuth();
                while(Navigator.canPop(context)) { //popできる状態ならする
                  Navigator.pop(context);
                }
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()
                ));
              },
              child: Text('アカウント削除')
          )
        ],
      ),
    ),
    ),
    );
  }
}
