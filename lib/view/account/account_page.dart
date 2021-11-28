import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fire/model/account.dart';
import 'package:flutter_fire/model/post.dart';
import 'package:flutter_fire/utils/authentication.dart';
import 'package:flutter_fire/utils/firestore/posts.dart';
import 'package:flutter_fire/utils/firestore/users.dart';
import 'package:flutter_fire/view/account/edit_account_page.dart';
import 'package:intl/intl.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Account myAccount = Authentication.myAccount!;
  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  // color: Colors.orange.withOpacity(0.3),
                  height: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                foregroundImage: NetworkImage(myAccount.imagePath),
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(myAccount.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                  SizedBox(width: 10),
                                  Text('@' + myAccount.userId, style: TextStyle(color: Colors.grey),),
                                ],
                              )
                            ],
                          ),
                          OutlinedButton(
                              onPressed: () async {
                                var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditAccountPage()));
                                if(result == true) {
                                  setState(() {
                                    myAccount = Authentication.myAccount!; //editAccountから持ってきたmuAccount
                                  });//myAccountを更新するよ〜
                                }
                              },
                              child: Text('編集')
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(myAccount.selfIntroduction)
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(
                          color: Colors.orange, width: 2 //このwidthは線の太さ
                      ))
                  ),
                  // ignore: prefer_const_constructors
                  child: Text('投稿',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold, fontSize: 20),),
                ),
                Expanded(child: StreamBuilder<QuerySnapshot>(
                  stream: UserFirestore.users.doc(myAccount.id)
                      .collection('my_posts')
                      .orderBy('created_time', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if(snapshot.hasData) {
                      List<String> myPostIds = List.generate(snapshot.data!.docs.length, (index) {
                        return snapshot.data!.docs[index].id;
                       });
                    return FutureBuilder<List<Post>?>(
                      future: PostFirestore.getPostsFromIds(myPostIds),
                      builder: (context, snapshot) {
                        if(snapshot.hasData) {
                        return ListView.builder(
                            physics: NeverScrollableScrollPhysics(), //投稿一覧のとこだけスクロールできなくする
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              Post post = snapshot.data![index];
                              return Container(
                                decoration: BoxDecoration(
                                    border: index == 0 ? Border(
                                      top: BorderSide(color: Colors.grey, width:0),
                                      bottom: BorderSide(color: Colors.grey, width:0),
                                    ) : Border(bottom: BorderSide(color: Colors.grey, width: 0),)
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20), //hor:左右余白、ver:上下余白
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      foregroundImage: NetworkImage(myAccount.imagePath),
                                    ),
                                    Expanded(
                                        child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 15),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(myAccount.name, style: TextStyle(fontWeight: FontWeight.bold),),
                                                        Text(myAccount.userId, style: TextStyle(color: Colors.grey),),
                                                      ],
                                                    ),
                                                    Text(DateFormat(' M/d/yy').format(post.createdTime!.toDate())) //toDateでDate型に変換
                                                  ],
                                                ),
                                                Text(post.content)
                                              ],
                                            )
                                        )
                                    )
                                  ],
                                ),
                              );
                            });
                        } else {
                        return Container();
    }
                      }
                    );
                    } else {
                      return Container();
                }
                  }
                )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
