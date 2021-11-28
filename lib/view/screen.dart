import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fire/view/account/account_page.dart';
import 'package:flutter_fire/view/time_line/post_page.dart';
import 'package:flutter_fire/view/time_line/time_line_page.dart';

class Screen extends StatefulWidget {
  const Screen({Key? key}) : super(key: key);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  int selectedIndex = 0; //今選択されているページの番号(家＝0,人＝1)
  List<Widget> pageList = [TimeLinePage(), AccountPage()]; //実際に表示するページの番号

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageList[selectedIndex], //本体に表示したいやつ
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: ''
          ),
          BottomNavigationBarItem(
          icon: Icon(Icons.perm_identity_outlined),
            label: ''
          )
        ],
        currentIndex: selectedIndex,
        onTap: (index) { //押したアイコンのindexを引数に入れる
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        elevation: 5,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PostPage())); //ルーティング
        },
        child: Icon(Icons.chat_bubble_outline),
      ),
    );
  }
}
