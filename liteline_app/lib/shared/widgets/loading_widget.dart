import 'package:flutter/material.dart';
import 'package:liteline_app/core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final Color? color;
  final double size;
  final String? message;

  const LoadingWidget({
    super.key,
    this.color = AppColors.primaryGreen,
    this.size = 24.0,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color!),
            strokeWidth: 2.0,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 8.0),
          Text(
            message!,
            style: TextStyle(color: color, fontSize: 14.0),
          ),
        ],
      ],
    );
  }
}