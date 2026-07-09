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
    final horizontalPadding = currentRoute == route ? 12.0 : 8.0;
    final colorText = currentRoute == route ? AppColors.brown : AppColors.gray;
    final backGroundColor = currentRoute == route
        ? AppColors.yellow
        : Colors.transparent;

    return InkWell(
      onTap: () => {onTap()},
      borderRadius: BorderRadius.circular(16),

      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 6,
          horizontal: horizontalPadding,
        ),
        decoration: BoxDecoration(
          color: backGroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconNav, color: colorText, size: 18),
              Text(
                title,
                style: TextStyle(
                  color: colorText,
                  fontSize: 11,
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
