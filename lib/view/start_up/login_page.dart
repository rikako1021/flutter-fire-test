import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fire/utils/authentication.dart';
import 'package:flutter_fire/utils/firestore/users.dart';
import 'package:flutter_fire/view/screen.dart';
import 'package:flutter_fire/view/start_up/create_account_page.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passController = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 60),
                Text('Flutter-Fire π', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.orange),),  //γ’γγͺγΏγ€γγ«
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Container(
                    width: 300,
                    child: TextField( //γ‘γ’γε₯εζ¬
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'γ‘γΌγ«γ’γγ¬γΉ'
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  child: TextField( //γγΉγ―γΌγε₯εζ¬
                    controller: passController,
                    decoration: InputDecoration(
                      hintText: 'γγΉγ―γΌγ'
                    ),
                  ),
                ),
                SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(text: 'γ’γ«γ¦γ³γγδ½ζγγ¦γγͺγζΉγ―'),
                        TextSpan(text: 'γγ‘γ',
                            style: TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
                            }
                        ),
                      ]
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton( //Navigator.pushγ―ζ»γγι·η§»γpushReplacementγ―ζ»γγͺγι·η§»
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange,
                      padding: EdgeInsets.symmetric(horizontal:30, vertical: 15),
                    ),
                    onPressed: () async{
                      var result = await Authentication.emailSignIn(
                          email: emailController.text,
                          pass: passController.text);
                      if(result is UserCredential) {
                        if(result.user!.emailVerified == true) {
                          var _result = await UserFirestore.getUser(
                              result.user!.uid);
                          if (_result == true) {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(
                                    builder: (context) => Screen()));
                          }
                        } else {
                          print('γ‘γΌγ«θͺθ¨Όγ§γγ¦γΎγγ');
                        }
                      }
                    },
                    child: Text('γ‘γΌγ«γ’γγ¬γΉγ§γ­γ°γ€γ³')
                ),
                SizedBox(height: 20),
                SignInButton(
                    Buttons.Google,
                    onPressed: () async {
                      var result = await Authentication.signInWithGoogle();
                      if (result is UserCredential) {
                        var result = await UserFirestore.getUser(Authentication.currentFirebaseUser!.uid);
                        print('result');
                        if (result == true) {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => Screen()));
                        } else {
                            Navigator.push(context,
                            MaterialPageRoute(builder: (context) => CreateAccountPage()));
                        }
                      }
                    }
                ), //FBγ¨γγγγγ«γ
              ],
            ),
          ),
        ),
      ),
    );
  }
}
