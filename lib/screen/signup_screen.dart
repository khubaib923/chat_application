import 'dart:developer';

import 'package:chat_app/model/ui_helper.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/screen/complete_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
  TextEditingController confirmPasswordController=TextEditingController();

  void checkValues(){

    String email=emailController.text.trim();
    String password=passwordController.text.trim();
    String confirmPassword=confirmPasswordController.text.trim();

    if(email == "" || password == "" || confirmPassword == "" ){
      UiHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the details");
      // log("Please fill all the details");
    }
    else if(password != confirmPassword){
      UiHelper.showAlertDialog(context, "Password Mismatch", "The passwords you entered do not match!");
      // log("Passwords do not match");
    }
    else{
     signUp(email, password);
    }
}

void signUp(String email,String password)async{
   UserCredential? userCredential;
   UiHelper.showLoadingDialog("Creating new account...", context);
    try{
      userCredential=await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    }
    on FirebaseException catch (e){
      Navigator.pop(context);
      UiHelper.showAlertDialog(context, "An error occured", e.message.toString());
      //log(e.code.toString());
    }
    if(userCredential != null){
      String uuid=userCredential.user!.uid;
      UserModel newUser=UserModel(
          uuid: uuid,
          fullName: "",
          email: email,
          profilePic: ""
      );

      await FirebaseFirestore.instance.collection("users").doc(uuid).set(newUser.toMap()).then((value){
        log("New User created");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CompleteProfileScreen(userModel: newUser, firebaseUser:userCredential!.user!)));
      });


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
                  const SizedBox(height: 10,),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: "Confirm Password"
                    ),
                  ),
                  const SizedBox(height: 20,),
                  CupertinoButton(onPressed: (){
                    checkValues();
                    //Navigator.push(context, MaterialPageRoute(builder: (context)=> CompleteProfileScreen()));
                  },color:Theme.of(context).colorScheme.secondary ,child: const Text("Sign Up"),)
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          const Text("Already have an account?",style: TextStyle(fontSize: 16),),
          CupertinoButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text("Login",style: TextStyle(color: Theme.of(context).colorScheme.secondary,fontSize: 16),)),
        ],
      ),
    );
  }
}
