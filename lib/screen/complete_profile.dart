import 'dart:developer';
import 'dart:io';

import 'package:chat_app/model/ui_helper.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/screen/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfileScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const CompleteProfileScreen({Key? key,required this.userModel,required this.firebaseUser}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {

  File? imageFile;
  TextEditingController fullNameController=TextEditingController();
  void showPhotoOptions(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text("Upload Profile Picture"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             ListTile(
               onTap: (){
                 Navigator.pop(context);
                 selectImage(ImageSource.gallery);
               },
               title: const Text("Select From Gallery"),
               leading: const Icon(Icons.photo_album),
             ),
            ListTile(
              onTap: (){
                Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take a photo"),
            )
          ],
        ),

      );
    });
  }

  void selectImage(ImageSource source)async{
    ImagePicker imagePicker=ImagePicker();
    XFile? pickedFile=await imagePicker.pickImage(source: source);
    if(pickedFile!=null){
      cropImage(pickedFile);
    }

  }
  void cropImage(XFile file) async{
    ImageCropper imageCropper=ImageCropper();
    CroppedFile? croppedImage=await imageCropper.cropImage(sourcePath: file.path,aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),compressQuality: 20);
    if(croppedImage!=null){
      setState(() {
        imageFile=File(croppedImage.path);
      });
    }

  }
  void checkValues(){

    String fullName=fullNameController.text.trim();
    if(fullName == "" || imageFile==null){
      // log("Please fill all the details");
      UiHelper.showAlertDialog(context, "Incomplete Data","Please fill all the details and upload a profile picture");
    }
    else{
      log("Uploading Data");
      uploadData();
    }
  }

  void uploadData()async{
    UiHelper.showLoadingDialog("Uploading image..", context);
    UploadTask uploadTask=FirebaseStorage.instance.ref("profilePictures").child(widget.userModel.uuid.toString()).putFile(imageFile!);
    TaskSnapshot snapshot=await uploadTask;
    String imageUrl=await snapshot.ref.getDownloadURL();
    String fullName=fullNameController.text.trim();
    widget.userModel.profilePic=imageUrl;
    widget.userModel.fullName=fullName;

    await FirebaseFirestore.instance.collection("users").doc(widget.userModel.uuid).set(widget.userModel.toMap()).then((value){
      log("Data Uploaded");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Profile"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          children:  [
            const SizedBox(height: 20,),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: (){
                showPhotoOptions();
              },
              child:  CircleAvatar(
                radius: 60,
                backgroundImage: imageFile!=null?FileImage(imageFile!):null,
                child:imageFile==null?const Icon(Icons.person,size: 50,):null ,
              ),
            ),
            const SizedBox(height: 15,),
             TextField(
              controller: fullNameController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  hintText: "Full Name"
              ),
            ),
            const SizedBox(height: 15,),
            CupertinoButton(onPressed: (){
              checkValues();
              //Navigator.push(context, MaterialPageRoute(builder: (context)=>const HomeScreen()));
            },color: Theme.of(context).colorScheme.secondary,child: const Text("Submit"),)

          ],
        ),
      ),
    );
  }
}


