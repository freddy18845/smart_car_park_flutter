import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../presentation/screens/admin_setup.dart';
import '../presentation/screens/car_park_space.dart';
import '../presentation/screens/home.dart';
import '../presentation/screens/login.dart';
import '../presentation/screens/setting_screen.dart';
import '../presentation/screens/transaction_history.dart';

//final String BASE_URL = "http://10.0.2.2:8000/api";
final String BASE_URL = "http://192.168.116.8:8000/api";
//php artisan serve --host=0.0.0.0 --port=8000
// php artisan schedule:work
//

final Map<String, Widget Function(Map<String, dynamic>? args)> appRoutes = {
  'home': (_) => HomeScreen(),
  'login': (_) => LoginScreen(),
  'admin_setup': (_) => AdminSetupScreen(),
  'reservations': (_) => ReservationHistoryScreen(),
  'settings': (_) => SettingScreen(),
  'space': (args) => CarParkSpaceScreen(
        carParkName: args?['carParkName'] ?? '',
        carParkID: args?['carParkID'] ?? 0,
      ),
};

// 2️⃣ Navigation function
void routeNavigation({
  required BuildContext context,
  required String pageName,
  Map<String, dynamic>? args, // extra data
}) {
  final pageBuilder = appRoutes[pageName];

  if (pageBuilder == null) {
    print("Error: Page '$pageName' not found in routes");
    return;
  }

  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      settings: RouteSettings(name: '/$pageName'),
      pageBuilder: (_, __, ___) => pageBuilder(args),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    ),
  );
}

Widget btnNavigator({
  required Color btnColor,
  required String text,
  bool isActive = false,
  bool isOutline = false,
  double height = 52,
}) {
  return Container(
    height: height,
    width: double.infinity,
    decoration: !isOutline
        ? BoxDecoration(
            color: btnColor,
            borderRadius: BorderRadius.circular(height == 52 ? 10 : 5),
          )
        : BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(height == 52 ? 10 : 5),
            border: Border.all(width: 1.5, color: btnColor)),
    child: Center(
      child: isActive
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.5,
              ),
            )
          : Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: height == 52 ? 15 : 10,
                fontWeight: FontWeight.w600,
                color: isOutline ? btnColor : Colors.white,
              ),
            ),
    ),
  );
}

Widget modalBtn(
    {required Color btnColor, required String text, required Color textColor}) {
  return Container(
    height: 40,
    width: double.infinity,
    decoration: BoxDecoration(
        color: btnColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: Colors.black)),
    child: Center(
      child: Text(
        text,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
      ),
    ),
  );
}

Widget customTextArea({
  TextEditingController? controller,
  String? hint,
  required int limit,
  ValueChanged<String>? onChanged,
  IconData? icon,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 5),
    decoration: BoxDecoration(
      color: Colors.grey.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.center,
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      maxLength: limit,
      minLines: 4, // 👈 minimum visible lines
      maxLines: 6, // 👈 allow up to 6 lines
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: hint ?? '',
        counterText: '',
        labelStyle: TextStyle(
          color: Colors.black.withOpacity(0.5),
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon:
            icon != null ? Icon(icon, size: 22, color: Colors.black) : null,
        alignLabelWithHint:
            true, // 👈 ensures label aligns with multi-line input
      ),
      cursorColor: Colors.black,
    ),
  );
}

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final int limit;
  final ValueChanged<String>? onChanged;
  final IconData? icon;

  const CustomTextField({
    Key? key,
    this.controller,
    this.hint,
    required this.limit,
    this.onChanged,
    this.icon,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.hint != null &&
        (widget.hint!.toLowerCase() == "password" ||
            widget.hint!.toLowerCase() == "confirm password");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        obscureText: _obscureText,
        maxLength: widget.limit,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: widget.hint ?? '',
          counterText: '',
          labelStyle: TextStyle(
            color: Colors.black.withOpacity(0.5),
            fontSize: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: widget.icon != null
              ? Icon(widget.icon, size: 22, color: Colors.black)
              : null,
          suffixIcon: (widget.hint?.toLowerCase() == "password" ||
                  widget.hint?.toLowerCase() == "confirm password")
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    _obscureText
                        ? Icons.remove_red_eye_outlined
                        : Icons.visibility_off_outlined,
                    size: 22,
                    color: Colors.black,
                  ),
                )
              : null,
        ),
        cursorColor: Colors.black,
      ),
    );
  }
}

Widget customDropdownField({
  String? hint,
  required List<String> items,
  required BuildContext context,
  TextEditingController? controller,
  String? value, // optional manual initial value
  ValueChanged<String?>? onChanged,
}) {
  // Compute a safe initial value: prefer controller.text if it's in items,
  // otherwise use the provided `value` if it's in items; else null.
  final safeValue = (controller != null && controller.text.isNotEmpty)
      ? (items.contains(controller.text) ? controller.text : null)
      : (value != null && items.contains(value) ? value : null);
  final Size size = MediaQuery.of(context).size;
  return Container(
    height: 52,
    width: double.infinity,
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.symmetric(horizontal: 10),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: Border.all(width: 1.0, color: Colors.black),
      borderRadius: BorderRadius.circular(10),
      color: Colors.grey.withValues(alpha: 0.2),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        value: safeValue,
        isExpanded: true,
        hint: Row(
          children: [
            Icon(Icons.car_crash_outlined, size: 22, color: Colors.black87),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: size.height * 0.4,
          width: size.width * 0.65,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: Colors.white),
          offset: const Offset(0, -4),
          scrollbarTheme: ScrollbarThemeData(
            crossAxisMargin: 4,
            thumbColor: WidgetStateProperty.all(Colors.grey[300]),
            mainAxisMargin: size.height * 0.025,
            radius: const Radius.circular(40),
            thickness: WidgetStateProperty.all<double>(4),
            thumbVisibility: WidgetStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
        isDense: true,
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ))
            .toList(),
        onChanged: (val) {
          if (controller != null) controller.text = val ?? '';
          if (onChanged != null) onChanged(val);
        },
      ),
    ),
  );
}

Widget timeCardBtn({required IconData icon, required Color iconColor}) {
  return Container(
    height: 40,
    width: 60,
    decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: Colors.black.withOpacity(0.3))),
    child: Center(
      child: Icon(
        icon,
        size: 25,
        color: iconColor,
      ),
    ),
  );
}

Color getSubSpaceColor(String status) {
  switch (status.toLowerCase()) {
    case 'available':
      return Colors.white;
    case 'booked':
      return Colors.amber;
    case 'reserved':
      return Colors.grey.shade600;
      case 'occupied':
      return Colors.grey.shade600;
    default:
      return Colors.green
          .withValues(alpha: 0.9); // fallback color for unknown status
  }
}

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  Color backgroundColor = Colors.green,
  double bottomMargin = 60,
}) {
  final size = MediaQuery.of(context).size;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor.withOpacity(0.9),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: size.height * 0.80,
        left: 20,
        right: 20,
      ),
    ),
  );
}

String formatDateTime(String? dateTime) {
  if (dateTime == null) return "";
  try {
    final parsed = DateTime.parse(dateTime);
    return DateFormat("dd MMM yyyy, hh:mm a").format(parsed);
    // Example: "10 Sep 2025, 10:37 AM"
  } catch (e) {
    return dateTime; // fallback in case parsing fails
  }
}
