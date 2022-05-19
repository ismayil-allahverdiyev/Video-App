import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_challenge/providers/authentication_service.dart';
import 'package:code_challenge/widgets/post_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Widget> listOfPosts = [];

  var user = FirebaseAuth.instance.currentUser;

  var userInfo;

  PageController? pageController;

  @override
  void initState() {
    // TODO: implement initState
    gettingInfo();
    pageController = PageController(initialPage: 0);
    super.initState();
  }

  Future<void> gettingInfo()async{
    userInfo = await FirebaseFirestore.instance.collection("Users").doc("${user?.email}").get();
  }

  final Stream<QuerySnapshot> videos = FirebaseFirestore.instance.collection("videos").snapshots();

  Future<Null> refreshList() async{
    setState(() {

    });
  }

  var icon = Icons.add;

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: (){
          AuthenticationService(FirebaseAuth.instance).signOut();
        },
        child: Center(
          child: Icon(Icons.logout, color: Colors.white,),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refreshList,
        child: GestureDetector(
          onTap: (){
            var currentScope = FocusScope.of(context);

            if(!currentScope.hasPrimaryFocus){
              currentScope.unfocus();
            }
          },
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: CircleAvatar(
                              radius: width*0.07,
                              backgroundColor: Colors.deepPurple,
                              child: Center(
                                child: CircleAvatar(
                                  radius: width*0.07-3,
                                  backgroundColor: Colors.white,
                                  child: Center(
                                    child: CircleAvatar(
                                      radius: width*0.07-6,
                                      backgroundColor: Colors.grey[100],
                                      child: Center(
                                        child: Icon(Icons.person, size: height*0.05, color: Colors.black,),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                            child: SizedBox(
                              width: width*0.45-24,
                              child: FutureBuilder(
                                future: gettingInfo(),
                                builder: (context, snapshot){
                                  if(snapshot.connectionState == ConnectionState.waiting){
                                    return Center(
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: CircularProgressIndicator()
                                          ),
                                        ],
                                      ),
                                    );
                                  }else{
                                    return FittedBox(
                                      child: Text(
                                        "${userInfo["name"]}",
                                        style: TextStyle(
                                            fontSize: height*0.03,
                                            color: Color(0xff3d405b),
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: (){
                            if(pageController?.page == 0){
                              pageController?.nextPage(duration: Duration(milliseconds: 300), curve: Curves.linear);
                              setState((){
                                icon = Icons.home;
                              });
                            }else{
                              pageController?.previousPage(duration: Duration(milliseconds: 300), curve: Curves.linear);
                              setState((){
                                icon = Icons.add;
                              });
                            }
                          },
                          child: Container(
                            height: width*0.08,
                            width: width*0.12,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(5),
                              // border: Border.all(color: Colors.black, width: 3, style: BorderStyle.solid)
                            ),
                            child: Icon(icon, color: Colors.white,)
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              
              SizedBox(
                height: height - width * 0.14 - 32,
                child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: [
                    SizedBox(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: videos,
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                          if(snapshot.hasError){
                            return Text("something went wrong");
                          }
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return Center(
                              child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator()
                              ),
                            );
                          }

                          final data = snapshot.requireData;

                          return ListView.builder(
                            itemCount: data.size,
                            itemBuilder: (context, value){
                              var postId = data.docs[value].id;
                              var userEmail = data.docs[value]["user"];
                              var description = data.docs[value]["description"];
                              var videoLink = data.docs[value]["video"];
                              var date = data.docs[value]["date"];
                              print("\n\n\n\n\n $userEmail $postId $videoLink $date");
                              return Column(
                                children: [
                                  PostWidget(postId: postId, userEmail: userEmail, description: description, videoLink: videoLink, date: date),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(width*0.1, 0, width*0.1, 0),
                                    child: Divider(thickness: 3, color: Colors.grey[300],),
                                  )
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    AddPage(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}