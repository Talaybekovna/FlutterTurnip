import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardMessage extends StatelessWidget {
  final String? text;

  const CardMessage(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(Icons.mail, color: Theme.of(context).colorScheme.tertiary),
        SizedBox(width: 8.w),
        Text(
          text!,
          style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 16.sp),
        ),
      ],
    );
  }
}