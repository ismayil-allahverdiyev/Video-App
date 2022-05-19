import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  ImagePicker _picker = ImagePicker();

  TextEditingController descriptionContoller = TextEditingController();

  var pickedFile;

  var checker = false;
  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
        onTap: (){
          var currentScope = FocusScope.of(context);

          if(currentScope.hasPrimaryFocus != true){
            currentScope.unfocus();
          }
        },
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
              child: Text(
                "Video",
                style: TextStyle(
                    color: Color(0xff3d405b),
                    fontWeight: FontWeight.bold,
                    fontSize: height*0.02
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: GestureDetector(
                onTap: ()async{
                  var picked = await _picker.pickVideo(source: ImageSource.gallery,);
                  setState((){
                    pickedFile = picked;
                    checker = true;
                  });
                },
                child: checker == false ? Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Container(
                    width: width,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Stack(
                          children: [
                            Icon(
                              CupertinoIcons.rectangle_fill_on_rectangle_angled_fill,
                              size: width*0.25,
                              color: Colors.grey[500],
                            ),
                            Positioned(
                              bottom: -width*0.03,
                              right: -width*0.03,
                              child: Icon(
                                  Icons.add,
                                color: Colors.grey[700],
                                size: width*0.1,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ) : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Center(
                          child: Text("Video chosen"),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 0, 0),
              child: Text(
                "Description",
                style: TextStyle(
                    color: Color(0xff3d405b),
                    fontWeight: FontWeight.bold,
                  fontSize: height*0.02
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: descriptionContoller,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: Color(0xff3d405b),
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                  child: GestureDetector(
                    onTap: () async{
                      File file = File(pickedFile!.path);
                      String videoId = "${Uuid().v1()}";
                      var listOfIds = [];
                      await FirebaseFirestore.instance.collection("Video ids").doc("ids").get().then((value) => listOfIds = value["ids"]);
                      listOfIds.add(videoId);
                      await FirebaseFirestore.instance.collection("Video ids").doc("ids").set({
                        "ids": listOfIds
                      });
                      final ref = FirebaseStorage.instance
                          .ref()
                          .child("Videos")
                          .child(videoId);
                      await ref.putFile(file);
                      String link = await ref.getDownloadURL();
                      FirebaseFirestore.instance.collection("videos").doc(videoId).set({
                        "user": FirebaseAuth.instance.currentUser?.email,
                        "video": link,
                        "date": "${DateTime.now()}",
                        "description": descriptionContoller.text,
                      });
                      setState((){
                        checker = false;
                        descriptionContoller.text = "";
                      });
                      var currentScope = FocusScope.of(context);

                      if(currentScope.hasPrimaryFocus != true){
                        currentScope.unfocus();
                      }
                    },
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Colors.deepPurpleAccent,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                            "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: height*0.02
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }
}
