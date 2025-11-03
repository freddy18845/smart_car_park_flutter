import 'package:flutter/material.dart';
import 'package:smart_carpark_app/presentation/screens/admin_setup.dart';
import 'package:smart_carpark_app/presentation/screens/setting_screen.dart';
import 'package:smart_carpark_app/presentation/screens/transaction_history.dart';
import '../utils/constant.dart';
import '../utils/storage_manage.dart';
import 'screens/home.dart';

class Footer extends StatefulWidget {
  final int activeNavIndex;


  const Footer({super.key, required this.activeNavIndex});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  String selectedBtn = '';
  final String userRole = StorageManager().getUserStatus();

  final List<Map<String, dynamic>> footerItems = [
    {"icon": Icons.home_outlined, "selectedIcon": Icons.home, "text": "Home"},
    {"icon": Icons.history_outlined, "selectedIcon": Icons.history, "text": "Reservations"},
    {"icon": Icons.settings_outlined, "selectedIcon": Icons.settings, "text": "Settings"},
  ];

  @override
  void initState() {
    super.initState();
    selectedBtn = _getInitialSelectedBtn() ?? 'Home';
  }

  String? _getInitialSelectedBtn() {
    try {
      if (footerItems.length > widget.activeNavIndex) {
        final text = footerItems[widget.activeNavIndex]["text"];
        if (text is String) {
          return text;
        }
      }
      return null;
    } catch (e) {
      print('Error in _getInitialSelectedBtn: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: Row(
        children: footerItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final text = item["text"] ?? 'Unknown';
          final icon = item["icon"] as IconData;
          final selectedIcon = item["selectedIcon"] as IconData;
          final isSelected = selectedBtn == text;

          return Expanded(
            child: InkWell(
              onTap: () {
                if (widget.activeNavIndex != index ) {
                  setState(() {
                    selectedBtn = text;
                  });
                  switch (index) {
                    case 0:
                      routeNavigation(context: context, pageName: 'home');



                      break;
                    case 1:
                      routeNavigation(context: context, pageName: 'reservations');


                      break;
                    case 2:

                      routeNavigation(context: context, pageName: 'settings');


                      break;
                  }
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 48,
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: isSelected
                        ? BoxDecoration(
                      color:Colors.grey.shade400,
                      border: Border.all(width: 2, color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color:Colors.grey.withOpacity(0.7),
                          offset: const Offset(0.1, 0.1),
                          blurRadius: 20.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    )
                        : const BoxDecoration(),
                    child: Center(
                      child: Icon(
                        isSelected ? selectedIcon : icon,
                        size: 20,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    text.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
