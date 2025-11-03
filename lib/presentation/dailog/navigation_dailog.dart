import 'package:flutter/material.dart';
import '../../utils/constant.dart';

class AlertDialog {
  static void show(BuildContext context,{required String title,required String message ,required bool isBooking}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 170,
            padding: const EdgeInsets.all(16.0),
            child:
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text(
                   title.toUpperCase(),
                  style:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
               Expanded(
                   child: Center(
                child: Text(
                  overflow:  TextOverflow.clip,
                  message,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
               )),


                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                        flex:1,
                        child: InkWell(onTap: (){
                        Navigator.pop(context);
                        },child:  modalBtn(btnColor: Colors.white, text: 'Cancel', textColor: Colors.black))),
                    SizedBox(width: 5,),
                    Expanded(
                      flex:1,
                      child:InkWell(onTap: (){
                        Navigator.pop(context);
                        // SettingDialog.show(context);
                      },
                          child: modalBtn(btnColor: Colors.black, text: 'Ok', textColor: Colors.white)),),
                  ],)
              ],
            ),
          ),
        );
      },
    );
  }
}
