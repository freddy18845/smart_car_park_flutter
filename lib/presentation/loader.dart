import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListLoader extends StatelessWidget {
  final Size size;
  const ListLoader({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Fetching Data", style: TextStyle(fontSize: 12,
            fontWeight: FontWeight.w300,
             ),),
        Container(
          padding: EdgeInsets.symmetric(vertical:size.height * 0.03 ),
          height: size.height * 0.1,
          width: size.height * 0.1,
          child: const CupertinoActivityIndicator(
            radius: 20,
          ),
        ),
        const Text("Please Wait..", style: TextStyle(fontSize: 12,
            fontWeight: FontWeight.w300,
            ),)
      ],
    );
  }
}
