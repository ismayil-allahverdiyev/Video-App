import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

import 'comment_widget.dart';

class PostWidget extends StatefulWidget {
  PostWidget({
    required this.postId,
    required this.userEmail,
    required this.description,
    required this.videoLink,
    required this.date,
    Key? key,
  }) : super(key: key);

  final postId;
  final userEmail;
  final description;
  final videoLink;
  final date;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  String userName = "";
  String duration = "00:00";
  VideoPlayerController? _controller;
  TextEditingController? commentController;
  Future<void>? _initializeVideoPlayerController;

  Future<void> getUserInfo() async{
    var value = await FirebaseFirestore.instance.collection("Users").doc(widget.userEmail).get();
    userName = value["name"];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
    getComments();
    _controller = VideoPlayerController.network("${widget.videoLink}");
    commentController = TextEditingController();
    _initializeVideoPlayerController = _controller!.initialize();
    _controller!.setLooping(true);
    _controller!.setVolume(1);
    _controller!.initialize().then((_) => setState(() {}));
    _controller!.pause();
  }

  var data;

  List<Widget> comments = [];

  Future<void> getComments() async{
    print("get comments");
    data = await FirebaseFirestore.instance.collection("videos").doc("${widget.postId}").collection("comments").snapshots().every((element) {
      comments = [];
      element.docs.forEach((element) {
        var user = element.data()["user"];
        var comment = element.data()["comment"];
        comments.add(CommentWidget(user: user, comment: comment));
        print("added ${comments.length}");
      });
      return  true;
    });
    print("printing");
    print(comments);

  }

  @override
  void dispose() {
    _controller!.dispose();
    commentController!.dispose();
    super.dispose();
  }

  bool isCommentsOpen = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    print("length");
    print(comments.length);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
        ),
        elevation: 10,
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    radius: width*0.06,
                    backgroundColor: Colors.deepPurple,
                    child: Center(
                      child: CircleAvatar(
                        radius: width*0.06-2,
                        backgroundColor: Colors.white,
                        child: Center(
                          child: CircleAvatar(
                            radius: width*0.06-4,
                            backgroundColor: Colors.grey[100],
                            child: Center(
                              child: Icon(Icons.person, size: height*0.03, color: Colors.black,),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: FutureBuilder(
                      future: getUserInfo(),
                      builder: (context, snapshot) {
                        return Text(
                          "$userName",
                          style: TextStyle(
                              fontSize: height*0.02,
                              color: Color(0xff3d405b),
                              fontWeight: FontWeight.bold
                          ),
                        );
                      }
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Stack(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black87
                      ),
                      height: width/3*2,
                      width: width,
                      child: FutureBuilder(
                        future: _initializeVideoPlayerController,
                        builder: (context, snapshot){
                          if(snapshot.connectionState == ConnectionState.done){
                            return Center(
                              child: AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              ),
                            );
                          }else{
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      )
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.black54
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          duration,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: (){

                        _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();

                        if(_controller!.value.duration.toString().substring(0, 2) == "0:"){
                          setState(() {
                            duration = _controller!.value.duration
                                .toString()
                                .substring(2, 7);
                          });
                        }
                        print(_controller!.value.duration);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.black54
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          child: Icon(
                            _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: FutureBuilder(
                        future: getUserInfo(),
                        builder: (context, snapshot) {
                          return RichText(
                            text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${userName}: ",
                                    style: TextStyle(
                                        fontSize: height*0.018,
                                        color: Color(0xff3d405b),
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  TextSpan(
                                    text: "${widget.description}",
                                    style: TextStyle(
                                      fontSize: height*0.018,
                                      color: Colors.black,
                                    ),
                                  )
                                ]
                            ),
                          );
                        }
                    )
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
              child: Row(
                children: [
                  isCommentsOpen == false ? GestureDetector(
                    onTap: (){
                      setState((){
                        isCommentsOpen = !isCommentsOpen;
                      });
                    },
                    child: Container(
                      color: Colors.white,
                      child: Text(
                        "View all comments",
                        style: TextStyle(
                            fontSize: height*0.015,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ) : SizedBox(
                    width: width-32,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: (){
                                  setState((){
                                    isCommentsOpen = !isCommentsOpen;
                                  });
                                },
                                icon: Icon(Icons.keyboard_arrow_up_outlined)
                            ),
                          ],
                        ),
                        Column(
                          children: comments,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: "Comment...",
                              suffixIcon: IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () async{
                                  print(widget.postId);
                                  await FirebaseFirestore.instance.collection("videos").doc("${widget.postId}").collection("comments").add({
                                    "user": FirebaseAuth.instance.currentUser!.email,
                                    "comment": commentController!.text
                                  }).then((value){
                                    setState((){
                                      commentController!.text = "";
                                    });
                                    var currentScope = FocusScope.of(context);

                                    if(currentScope.hasPrimaryFocus != true){
                                      currentScope.unfocus();
                                    }
                                  });

                                },
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}