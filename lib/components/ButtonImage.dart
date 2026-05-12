import 'package:flutter/material.dart';

class ButtonImage extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  ButtonImage({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        width: double.infinity,
        child: Column(
          children: [
            Icon(icon, color: textColor, size: 40),
            SizedBox(height: 16),
            Text(
              text,
              style: TextStyle(
                fontSize: 24,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
