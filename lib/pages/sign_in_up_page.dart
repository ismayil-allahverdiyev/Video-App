import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_challenge/providers/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'home_page.dart';

class SignInUpPage extends StatefulWidget {
  const SignInUpPage({Key? key}) : super(key: key);

  @override
  State<SignInUpPage> createState() => _SignInUpPageState();
}

class _SignInUpPageState extends State<SignInUpPage> {

  bool isSwitched = false;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  TextEditingController? userNameController;
  TextEditingController? emailController;
  TextEditingController? passwordController;
  TextEditingController? repeatPasswordController;

  AuthenticationService? authenticationService;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authenticationService = AuthenticationService(firebaseAuth);
    userNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    repeatPasswordController = TextEditingController();
  }
  var passwordColor = Color(0xff8661c1);

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    var choice1 = Text(
      "Sign in",
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: height*0.03,
          color: Color(0xff3d405b),
          fontWeight: FontWeight.bold
      ),
    );

    var choice2 = Text(
      "Sign up",
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: height*0.03,
          color: Color(0xff3d405b),
          fontWeight: FontWeight.bold
      ),
    );

    return Scaffold(
      body: GestureDetector(
        onTap: (){
          var currentScope = FocusScope.of(context);

          if(currentScope.hasPrimaryFocus != true){
            currentScope.unfocus();
          }
        },
        child: Stack(
          children: [
            ListView(
              children: [
                SizedBox(height: height*0.2,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedSize(
                        duration: Duration(milliseconds: 500),
                        child: Container(
                            child: isSwitched == false ? choice1 : Text("")
                        ),
                      ),
                      Transform.scale(
                        scale: 1,
                        child: Switch(
                          activeTrackColor: Color(0xff8661c1),
                          value: isSwitched,
                          onChanged: (value){
                            setState(() {
                              isSwitched = value;
                            });
                          },
                          activeColor: Color(0xff4221c1),
                          // activeTrackColor: Color(0xff00a7e1),
                          inactiveThumbColor: Color(0xff8661c1),
                        ),
                      ),
                      AnimatedSize(
                        duration: Duration(milliseconds: 500),
                        child: Container(
                            child: isSwitched == true ? choice2 : Text("")
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  child: isSwitched == true ?
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          controller: userNameController,
                          maxLength: 15,
                          decoration: InputDecoration(
                              hintText: "Username",
                              icon: Icon(Icons.person, color: Color(0xff8661c1),),
                          ),
                        ),
                      ),
                    ),
                  ) : Container(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                            hintText: "E-mail",
                            icon: Icon(Icons.email, color: Color(0xff8661c1),),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            hintText: "Password",
                            icon: Icon(Icons.key, color: passwordColor,),
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  child: isSwitched == true ?
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          controller: repeatPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              hintText: "Repeat password",
                              icon: Icon(Icons.key, color: passwordColor,),
                          ),
                        ),
                      ),
                    ),
                  ) : Container(),
                )
              ],
            ),
            Positioned(
              child: GestureDetector(
                onTap: (){
                  if(isSwitched == false){
                    if(emailController!.text.isEmpty || passwordController!.text.isEmpty){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Incomplete information!"),
                      ));
                    }else{
                      authenticationService?.signIn(email: emailController?.text, password: passwordController?.text);
                    }
                  }else {
                    if(passwordController!.text != repeatPasswordController!.text){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Passwords are not matching!"),
                      ));
                      setState((){
                        passwordColor = Color(0xffe00013);
                      });
                    }if(userNameController!.text.isEmpty || emailController!.text.isEmpty || passwordController!.text.isEmpty || repeatPasswordController!.text.isEmpty){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Incomplete information!"),
                      ));
                    }else{
                      authenticationService?.signUp(email: emailController?.text, password: passwordController?.text);
                      var firestoreInstance = FirebaseFirestore.instance;
                      firestoreInstance.collection("Users").doc(emailController?.text).set({
                        "name": userNameController?.text,
                        "email": emailController?.text
                      });
                    }
                  }
                },
                child: Card(
                  color: Color(0xff4221c1),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Text(
                      isSwitched == false ? "Sign in" : "Sign up",
                      style: TextStyle(
                          fontSize: height*0.02,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
              bottom: 20,
              right: 20,
            )
          ],
        ),
      ),
    );
  }
}
