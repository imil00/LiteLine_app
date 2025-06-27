import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for FilteringTextInputFormatter
import 'package:liteline_app/core/constants/app_colors.dart';
import 'package:liteline_app/core/constants/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Dapatkan warna teks dari tema yang aktif (light/dark)
    final Color primaryTextColor = Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final Color secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final Color hintAndLabelColor = Theme.of(context).hintColor;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted, // Gunakan onFieldSubmitted untuk TextFormField
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      readOnly: readOnly,
      onTap: onTap,
      // Gunakan AppTextStyles sebagai dasar, lalu override warnanya dengan warna tema
      style: AppTextStyles.bodyLarge.copyWith(color: primaryTextColor),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        // Gunakan AppTextStyles sebagai dasar, lalu override warnanya dengan warna hint tema
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: hintAndLabelColor),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: hintAndLabelColor),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: Theme.of(context).iconTheme.color,
              )
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        counterText: '', // Sembunyikan counter maxLength default
      ),
    );
  }
}
