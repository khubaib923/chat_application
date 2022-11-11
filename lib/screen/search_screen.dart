import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/model/chat_room_model.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/screen/chat_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchScreen({Key? key,required this.userModel,required this.firebaseUser}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController emailController=TextEditingController();

  Future<ChatRoomModel?>getChatRoomModel(UserModel targetUser) async{
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uuid}",isEqualTo: true).where("participants.${targetUser.uuid}",isEqualTo: true).get();
    if(snapshot.docs.isNotEmpty){
      //Fetch the existing one
      // log("chat room already created");
     var docData= snapshot.docs[0].data();
     ChatRoomModel exitingChatRoom=ChatRoomModel.fromMap(docData as Map<String,dynamic>);
     chatRoom=exitingChatRoom;

    }
    else{
      //create a new one
     ChatRoomModel newChatRoom=ChatRoomModel(
       chatRoomId: uuid.v1(),
       lastMessage: "",
       createdOn: DateTime.now(),
       participants: {
         widget.userModel.uuid.toString():true,
         targetUser.uuid.toString():true
       },
       users: [
         widget.userModel.uuid.toString(),targetUser.uuid.toString()
       ]
       );
     await FirebaseFirestore.instance.collection("chatrooms").doc(newChatRoom.chatRoomId).set(newChatRoom.toMap());
     chatRoom=newChatRoom;
     log("new chatroom created");

    }
    return chatRoom;




  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:const Text("Search"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
          child: Column(
            children: [
               TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    hintText: "Email Address"
                ),
              ),
              const SizedBox(height: 20,),
              CupertinoButton(onPressed: (){
                setState(() {});

              },color: Theme.of(context).colorScheme.primary,child: const Text("Search"),),
              const SizedBox(height: 20,),
              StreamBuilder(
                stream:FirebaseFirestore.instance.collection("users").where("email",isEqualTo: emailController.text).where("email",isNotEqualTo: widget.firebaseUser.email).snapshots() ,
                  builder:(context,snapshot){
                  if(snapshot.connectionState==ConnectionState.active){
                    if(snapshot.hasData){
                      QuerySnapshot dataSnapshot=snapshot.data as QuerySnapshot;
                      if(dataSnapshot.docs.isNotEmpty){
                        Map<String,dynamic> userMap=dataSnapshot.docs[0].data() as Map<String,dynamic>;
                        UserModel searchedUser=UserModel.fromMap(userMap);
                        return ListTile(
                          onTap: ()async{
                            ChatRoomModel? chatRoomModel=await getChatRoomModel(searchedUser);
                           if(chatRoomModel!=null){
                             if(mounted){
                               Navigator.pop(context);
                               Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatRoomScreen(targetUser: searchedUser,firebaseUser: widget.firebaseUser,userModel: widget.userModel,chatRoom:chatRoomModel)));
                             }
                           }

                          },
                          leading: CircleAvatar(
                            backgroundImage:NetworkImage(searchedUser.profilePic.toString()),
                            backgroundColor: Colors.grey[500],

                          ),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          title: Text(searchedUser.fullName.toString()),
                          subtitle: Text(searchedUser.email.toString(),style:const TextStyle(fontSize: 13),),
                        );

                      }
                      else{
                        return const Text("No results found!");

                      }

                    }
                    else if(snapshot.hasError){
                      return const Text("An error occured!");

                    }
                    else{
                      return const Text("No results found!");

                    }



                  }
                  else{
                    return const CircularProgressIndicator();
                  }

                  }

              )

            ],
          ),
        ),
      ),
    );
  }
}
