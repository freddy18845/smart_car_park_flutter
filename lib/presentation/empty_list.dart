import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyList extends StatelessWidget {
  final Size size;
  const EmptyList({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Padding(
        padding: EdgeInsets.only(bottom: size.height * 0.09),
        child: Center(
            child:Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 15,),
        Icon(Icons.widgets_outlined, size: size.width * 0.3, color: Colors.grey.shade400,),
        Text(
          "No  Data",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
        ),
      ],
    ))));
  }
}
