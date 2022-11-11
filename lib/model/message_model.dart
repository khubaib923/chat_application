class MessageModel{
  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdOn;

  MessageModel({required this.sender,required this.text,required this.seen,required this.createdOn,required this.messageId});

  MessageModel.fromMap(Map<String,dynamic>map){
    sender=map["sender"];
    text=map["text"];
    seen=map["seen"];
    createdOn=map["createdOn"].toDate();
    messageId=map["messageId"];
  }

  Map<String,dynamic>toMap(){
    return {
      "sender":sender,
      "text":text,
      "seen":seen,
      "createdOn":createdOn,
      "messageId":messageId,
    };
  }

}