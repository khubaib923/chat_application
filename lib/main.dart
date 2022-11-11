import 'package:chat_app/model/firebase_helper.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/screen/complete_profile.dart';
import 'package:chat_app/screen/home_screen.dart';
import 'package:chat_app/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid=const Uuid();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentUser=FirebaseAuth.instance.currentUser;
  if(currentUser != null){
    UserModel? thisUserModel=await FirebaseHelper.getUserById(currentUser.uid);
    if(thisUserModel != null){
      runApp(MyAppLogin(userModel:thisUserModel , firebaseUser: currentUser));
    }
    else{
      runApp(const MyApp());
    }

  }
  else{
    runApp(const MyApp());
  }
  
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class MyAppLogin extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const MyAppLogin({Key? key,required this.userModel,required this.firebaseUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
