import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentWidget extends StatefulWidget {
  const CommentWidget({Key? key, required this.user, required this.comment}) : super(key: key);

  final String user;
  final String comment;

  @override
  State<CommentWidget> createState() => _CommentWidgetState();

}

class _CommentWidgetState extends State<CommentWidget> {

  var userName = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async{
    var futureData = await FirebaseFirestore.instance.collection("Users").doc(widget.user).get();
    userName = futureData.data()?['name'];
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Container(
                      width: width-48-width*0.12,
                      child: FutureBuilder(
                        future: getUserInfo(),
                        builder: (context, snapshot){
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return Row(
                              children: [
                                CircularProgressIndicator(),
                              ],
                            );
                          }else{
                            return RichText(
                              text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "${userName}\n",
                                        style: TextStyle(
                                            fontSize: height*0.015,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold
                                        )
                                    ),
                                    TextSpan(
                                        text: "${widget.comment}",
                                        style: TextStyle(
                                          fontSize: height*0.015,
                                          color: Colors.black,
                                        )
                                    ),
                                  ]
                              ),
                            );
                          }
                        }
                      )
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(width/10, 0, width/10, 0),
              child: Divider(
                thickness: 3,
                color: Colors.grey[300],
              ),
            )
          ],
        ),
      );
  }
}