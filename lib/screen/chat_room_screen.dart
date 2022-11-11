import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/model/chat_room_model.dart';
import 'package:chat_app/model/message_model.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatelessWidget {
  final UserModel targetUser;
  final ChatRoomModel chatRoom;
  final UserModel userModel;
  final User firebaseUser;
  const ChatRoomScreen({Key? key,required this.targetUser,required this.chatRoom,required this.userModel,required this.firebaseUser}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    TextEditingController messageController=TextEditingController();

    void sendMessages()async{
      String message=messageController.text.trim();
      messageController.clear();
      if(message!=""){
        MessageModel newMessage=MessageModel(sender: userModel.uuid, text: message, seen: false, createdOn: DateTime.now(), messageId: uuid.v1());
        FirebaseFirestore.instance.collection("chatrooms").doc(chatRoom.chatRoomId).collection("messages").doc(newMessage.messageId).set(newMessage.toMap());
         log("message sent");
         chatRoom.lastMessage=message;
         chatRoom.createdOn=newMessage.createdOn;
         FirebaseFirestore.instance.collection("chatrooms").doc(chatRoom.chatRoomId).set(chatRoom.toMap());
      }
    }
    return Scaffold(

      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(targetUser.profilePic.toString()),
            ),
            const SizedBox(width: 10,),
            Text(targetUser.fullName.toString()),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("chatrooms").doc(chatRoom.chatRoomId).collection("messages").orderBy("createdOn",descending: true).snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState==ConnectionState.active){
                      if(snapshot.hasData){
                       QuerySnapshot dataSnapshot= snapshot.data as QuerySnapshot;

                       return ListView.builder(

                         reverse: true,
                           itemCount:dataSnapshot.docs.length ,
                           itemBuilder:(context,index){
                             Map<String,dynamic>data=dataSnapshot.docs[index].data() as Map<String,dynamic>;
                             MessageModel currentMessage=MessageModel.fromMap(data);
                             return Row(
                               mainAxisAlignment:currentMessage.sender==userModel.uuid?MainAxisAlignment.end:MainAxisAlignment.start,
                               children: [
                                 Container(
                                   margin: const EdgeInsets.symmetric(vertical: 2),
                                   padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                     decoration: BoxDecoration(
                                       color:currentMessage.sender==userModel.uuid?Colors.grey: Theme.of(context).colorScheme.primary,
                                       borderRadius: BorderRadius.circular(5),
                                     ),
                                     child: Text(currentMessage.text.toString(),style: const TextStyle(color: Colors.white),)),
                               ],
                             );

                           }
                       );


                      }
                      else if(snapshot.hasError){
                        return const Center(child: Text("An error occured!Please check your internet connection."));
                      }
                      else{
                        return const Center(
                          child: Text("Say hi to your new friend"),
                        );

                      }
                    }
                    else{
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              )
          ),
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
            child: Row(
              children: [
                Flexible(
                    child: TextField(
                      controller: messageController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter message"
                      ),
                    )
                ),
                IconButton(
                    onPressed: (){
                      sendMessages();
                    },
                    icon:Icon(Icons.send,color: Theme.of(context).colorScheme.primary,))
              ],
            ),
          )
        ],
      ),


    );
  }
}
