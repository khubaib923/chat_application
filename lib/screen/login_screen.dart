import 'dart:developer';

import 'package:chat_app/model/ui_helper.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/screen/home_screen.dart';
import 'package:chat_app/screen/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController=TextEditingController();
  TextEditingController passwordController=TextEditingController();

  void checkValues(){

    String email=emailController.text.trim();
    String password=passwordController.text.trim();
    if(email == "" || password == ""){
      UiHelper.showAlertDialog(context, "Incomplete Data","Please fill all the details");
      //log("Please fill all the details");
    }
    else{
      login(email, password);
    }
  }
  void login(String email,String password)async{

    UserCredential? userCredential;
    UiHelper.showLoadingDialog("Loading...", context);

    try{
      userCredential=await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    }
    on FirebaseAuthException catch(e){
      //close the loading dialog
      Navigator.pop(context);
     UiHelper.showAlertDialog(context, "An error occured",e.message.toString());
      //log(e.message.toString());
    }

    if(userCredential != null){
      String uuid=userCredential.user!.uid;

     DocumentSnapshot userData= await FirebaseFirestore.instance.collection("users").doc(uuid).get();
     UserModel userModel=UserModel.fromMap(userData.data() as Map<String,dynamic>);
     //log(userModel.email.toString());
     log("Login Successfully");
     if(mounted){
       Navigator.popUntil(context, (route) => route.isFirst);
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen(userModel: userModel, firebaseUser:userCredential!.user!)));
     }

    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Chat App",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.secondary),),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Email Address"
                    ),
                  ),
                  const SizedBox(height: 10,),
                   TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: "Password"
                    ),
                  ),
                  const SizedBox(height: 20,),
                  CupertinoButton(onPressed: (){
                    checkValues();
                  },color:Theme.of(context).colorScheme.secondary ,child: const Text("Login"),)
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          const Text("Don't have an account?",style: TextStyle(fontSize: 16),),
          CupertinoButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const SignUpScreen()));
              },
              child: Text("Sign Up",style: TextStyle(color: Theme.of(context).colorScheme.secondary,fontSize: 16),)),
        ],
      ),
    );
  }
}
