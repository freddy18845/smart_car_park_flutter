import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/constant.dart';

class StatusRow extends StatefulWidget {
  const StatusRow({super.key});

  @override
  State<StatusRow> createState() => _StatusRowState();
}

class _StatusRowState extends State<StatusRow> {
  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        rowData(
          text: 'Available',
          iconColor: getSubSpaceColor("available"),
        ),
        rowData(
            text: 'Booked',
            iconColor: getSubSpaceColor("booked")),
        rowData(
          text: 'Unavailable',
          iconColor: getSubSpaceColor("occupied"),
        ),
        rowData(
          text: 'Selected Lot',
          iconColor: getSubSpaceColor("Selected Lot"),
        ),
      ],
    );
  }
}
Widget rowData({required String text, required Color iconColor}) {
  return Row(
    children: [
      Container(
          height: 16,
          width: 16,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                width: 0.9,
                color:
                text == 'Available' ? Colors.grey : Colors.transparent),
          )),
      const SizedBox(width: 5),
      Text(
        text,
        style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12),
      ),
    ],
  );
}
