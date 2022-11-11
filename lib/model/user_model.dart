class UserModel{
     String? uuid;
     String? fullName;
     String? email;
     String? profilePic;

  UserModel({required this.uuid,required this.fullName,required this.email,required this.profilePic});

   UserModel.fromMap(Map<String,dynamic>map){

    uuid=map["uuid"];
    fullName=map["fullName"];
    email=map["email"];
    profilePic=map["profilePic"];
   }

   Map<String,dynamic>toMap(){
     return {
       "uuid":uuid,
       "fullName":fullName,
       "email":email,
       "profilePic":profilePic
     };
   }

}