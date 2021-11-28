import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fire/model/account.dart';
import 'package:flutter_fire/model/post.dart';
import 'package:flutter_fire/utils/firestore/posts.dart';
import 'package:flutter_fire/utils/firestore/users.dart';
import 'package:flutter_fire/view/time_line/post_page.dart';
import 'package:intl/intl.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('タイムライン', style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.orange,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: PostFirestore.posts.orderBy('created_time', descending: true).snapshots(), //postsにデータが追加されるたびにこのビルダーがうごく
        builder: (context, postSnapshot) {
          if(postSnapshot.hasData) {
            List<String> postAccountIds = [];
            postSnapshot.data!.docs.forEach((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              if(!postAccountIds.contains(data['post_account_id'])) { //もしidsリストにないユーザーidならlistに追加する
                postAccountIds.add(data['post_account_id']);
              }
            }); //どのユーザーの投稿なのかチェック
            return FutureBuilder<Map<String, Account>?>(
              future: UserFirestore.getPostUserMap(postAccountIds),
              builder: (context, userSnapshot) {
                if(userSnapshot.hasData && userSnapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                    itemCount: postSnapshot.data!.docs.length, //何個表示するか
                    // 何を表示するか
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data = postSnapshot.data!.docs[index].data() as Map<String, dynamic>;
                      Post post = Post ( //postのインスタンス作る
                        id: postSnapshot.data!.docs[index].id,
                        content: data['content'],
                        postAccountId: data['post_account_id'],
                        createdTime: data['created_time'],
                      );
                      Account postAccount = userSnapshot.data![post.postAccountId]!;
                    return Container(
                      decoration: BoxDecoration(
                          border: index == 0 ? Border(
                            top: BorderSide(color: Colors.grey, width: 0),
                            bottom: BorderSide(color: Colors.grey, width: 0),
                          ) : Border(bottom: BorderSide(color: Colors.grey,
                              width: 0),)
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      //hor:左右余白、ver:上下余白
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            foregroundImage: NetworkImage(postAccount.imagePath),
                          ),
                          Expanded(
                              child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(postAccount.name, style: TextStyle(
                                                  fontWeight: FontWeight.bold),),
                                              SizedBox(width: 10),
                                              Text('@' + postAccount.userId,
                                                style: TextStyle(
                                                    color: Colors.grey),),
                                            ],
                                          ),
                                          Text(DateFormat(' M/d/yy').format(
                                              post.createdTime!
                                                  .toDate()))
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
                  },
                );
                } else {
                  return Container();
                }
              }
            );
          } else {
            return Container();
          }
        }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        elevation: 3,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PostPage())); //ルーティング
        },
        child: Icon(Icons.chat_bubble_outline),
      ),
    );
  }
}
