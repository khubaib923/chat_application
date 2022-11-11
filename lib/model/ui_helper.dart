import 'package:flutter/material.dart';

class UiHelper{
  static void showLoadingDialog(String title,BuildContext context){
    AlertDialog loadingDialog=AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
         mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 30,),
            Text(title)
          ],
        ),
      ),
    );
    showDialog(
        barrierDismissible: false,
        context: context, builder:(context){
      return loadingDialog;
    });
  }

  static void showAlertDialog(BuildContext context,String title,String content){
    AlertDialog alertDialog=AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: (){
          Navigator.pop(context);
        }, child: const Text("Ok")),
      ],

    );

    showDialog(context: context, builder: (context)=>alertDialog);


  }
}