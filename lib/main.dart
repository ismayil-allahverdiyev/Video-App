import 'package:code_challenge/pages/home_page.dart';
import 'package:code_challenge/pages/sign_in_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:code_challenge/providers/authentication_service.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
      MultiProvider(
        providers: [
          Provider<AuthenticationService>(create: (_) => AuthenticationService(FirebaseAuth.instance),),
        ],
        child: const MaterialApp(
            home: MyApp()
        ),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthenticationService(FirebaseAuth.instance).authService,
      builder: (context, snapshot) {
        Widget returnedChild;
        if(snapshot.connectionState == ConnectionState.waiting){
          returnedChild = CircularProgressIndicator();
        }else{
          if (snapshot.data == null) {
            returnedChild = SignInUpPage();
          }else{
            returnedChild = HomePage();
          }
        }
        return returnedChild;
      },

    );
    //
    // final firebaseUser = context.watch<User?>();
    // if(firebaseUser!=null){
    //   return HomePage();
    // }
    // return SignInUpPage();
  }
}