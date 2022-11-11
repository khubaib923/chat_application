import 'package:chat_app/model/chat_room_model.dart';
import 'package:chat_app/model/firebase_helper.dart';
import 'package:chat_app/model/ui_helper.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/screen/chat_room_screen.dart';
import 'package:chat_app/screen/login_screen.dart';
import 'package:chat_app/screen/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomeScreen({Key? key,required this.userModel,required this.firebaseUser}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat App"),
        actions: [
          IconButton(onPressed: () async{
            await FirebaseAuth.instance.signOut().then((value){
             Navigator.popUntil(context, (route) => route.isFirst);
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const LoginScreen()));
            });
          }, icon: const Icon(Icons.logout))
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child:StreamBuilder(
          // stream: FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uuid}",isEqualTo: true).snapshots(), without orderBy because participants is a map.
          stream: FirebaseFirestore.instance.collection("chatrooms").where("users",arrayContains: widget.userModel.uuid).orderBy("createdOn",descending: true).snapshots(),
          builder: (context,snapshot){
            if(snapshot.connectionState==ConnectionState.active){
              if(snapshot.hasData){
                QuerySnapshot dataSnapshot=snapshot.data as QuerySnapshot;
                return ListView.builder(
                    itemCount: dataSnapshot.docs.length,
                    itemBuilder: (context,index){
                      Map<String,dynamic> data=dataSnapshot.docs[index].data() as Map<String,dynamic>;
                      ChatRoomModel chatRoomModel=ChatRoomModel.fromMap(data);
                      Map<String,dynamic>? participants=chatRoomModel.participants;
                      List<String>participantKeys= participants!.keys.toList();
                      participantKeys.remove(widget.userModel.uuid);
                      return FutureBuilder(
                          future: FirebaseHelper.getUserById(participantKeys[0]),
                          builder: (context,userData){
                            if(userData.connectionState==ConnectionState.done){
                              if(userData.data != null){
                                UserModel targetUser=userData.data as UserModel;
                                return ListTile(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatRoomScreen(targetUser: targetUser, chatRoom:chatRoomModel, userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(targetUser.profilePic.toString()),
                                    backgroundColor: Colors.grey[300],
                                  ),
                                  title: Text(targetUser.fullName.toString()),
                                  subtitle:chatRoomModel.lastMessage != ""? Text(chatRoomModel.lastMessage.toString()):Text("Say hi to your new friend!",style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                                );
                              }
                              else{
                                return Container();
                              }
                            }
                            else{
                              return Container();
                            }

                          }
                      );




                    }
                );

              }
              else if(snapshot.hasError){
                return Center(
                  child: Text(snapshot.error.toString()),
                );

              }
              else{
                return const Center(
                  child: Text("No chats"),
                );
              }

            }
            else{
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ) ,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          //UiHelper.showLoadingDialog("loading...",context);
          Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
        },
        child: const Icon(Icons.search),
      ),

    );
  }
}
