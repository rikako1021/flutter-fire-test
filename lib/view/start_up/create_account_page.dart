import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fire/model/account.dart';
import 'package:flutter_fire/utils/authentication.dart';
import 'package:flutter_fire/utils/firestore/users.dart';
import 'package:flutter_fire/utils/function_utils.dart';
import 'package:flutter_fire/utils/widget_utils.dart';
import 'package:flutter_fire/view/screen.dart';
import 'package:flutter_fire/view/start_up/check_email_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/authentication.dart';

class CreateAccountPage extends StatefulWidget {
  final bool isSignInWithGoogle; //Googleからのログインかそうじゃないかが入る変数
  CreateAccountPage({this.isSignInWithGoogle = false}); //基本はfalse

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfIntroductionController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  File? image;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.createAppBar('新規登録'),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column( // 登録情報記入欄
            children: [
              SizedBox(height: 30),
              GestureDetector(
                onTap: () async {
                  var result = await FunctionUtils.getImageFromGallery();
                  if(result != null) {
                    setState(() {
                          image = File(result.path);
                        });
                  }
                },
                child: CircleAvatar(
                  foregroundImage: image == null ? null : FileImage(image!), //imageがnullの場合は非表示で、そうでない場合はimageを表示
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
              widget.isSignInWithGoogle ? Container() : Column( //isSignInWithGoogleがtrueならContainerを表示、falseならColumnを表示
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Container(
                        width: 300,
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(hintText: 'メールアドレス'),
                        ),
                      ),
                  ),
                  Container(
                    width: 300,
                    child: TextField(
                      controller: passController,
                      decoration: InputDecoration(hintText: 'ぱすわーど'),
                    ),
                  ),
                ],
              ),
                SizedBox(height: 50),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange,
                      padding: EdgeInsets.symmetric(horizontal:30, vertical: 15),
                    ),
                  onPressed: () async{
                    if(nameController.text.isNotEmpty
                        && userIdController.text.isNotEmpty
                        && selfIntroductionController.text.isNotEmpty
                       ) {
                      if(widget.isSignInWithGoogle) {
                        var _result = await createAccount(Authentication.currentFirebaseUser!.uid);
                        if(_result == true) {
                          await UserFirestore.getUser(Authentication.currentFirebaseUser!.uid);
                          Navigator.pop(context);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Screen()));
                        }
                      }
                      var result = await Authentication.signUp(
                          email: emailController.text,
                          pass: passController.text);
                      if (result is UserCredential) { //newAccount(UserCredential)が帰ってくるなら作成成功してるので、帰ってくるのがUserCredentialかどうかで分岐する
                        var _result = await createAccount(result.user!.uid);
                         if(_result == true) {
                           result.user!.sendEmailVerification();
                           Navigator.push(context, MaterialPageRoute(builder: (context) => CheckEmailPage(
                             email: emailController.text,
                             pass: passController.text)
                           ));
                           Navigator.pop(context);
                         }
                      }
                    }
                  },
                  child: Text('アカウントを作成', style: TextStyle(fontSize: 17)),
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<dynamic> createAccount(String uid) async{
    String imagePath = await FunctionUtils.uploadImage(uid, image!); //resultの中に入ってるuserっていうデータのuidをとってくる
    Account newAccount = Account(
      id: uid,
      name: nameController.text,
      userId: userIdController.text,
      selfIntroduction: selfIntroductionController.text,
      imagePath: imagePath,
    );
    var _result = await UserFirestore.setUser(newAccount);
    return _result;
  }
}
