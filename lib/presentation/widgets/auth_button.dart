// lib/presentation/widgets/auth_button.dart

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AuthButton extends StatelessWidget {
  final String   label;
  final VoidCallback? onPressed;
  final bool     isLoading;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child:     isLoading
            ? const SizedBox(
                width:  20,
                height: 20,
                child:  CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color:       AppColors.onAccent,
                ),
              )
            : Text(label),
      ),
    );
  }
}