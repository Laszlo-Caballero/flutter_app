import 'package:app_machin/utils/colors.dart';
import 'package:flutter/material.dart';

class Iconnavbar extends StatelessWidget {
  final IconData iconNav;
  final String title;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;

  const Iconnavbar({
    super.key,
    required this.iconNav,
    required this.title,
    required this.route,
    required this.currentRoute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = currentRoute == route ? 24.0 : 16.0;
    final colorText = currentRoute == route ? AppColors.brown : AppColors.gray;
    final backGroundColor = currentRoute == route
        ? AppColors.yellow
        : Colors.transparent;

    return InkWell(
      onTap: () => {onTap()},
      borderRadius: BorderRadius.circular(16),

      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: horizontalPadding,
        ),
        decoration: BoxDecoration(
          color: backGroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(iconNav, color: colorText, size: 20),
              Text(
                title,
                style: TextStyle(
                  color: colorText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
