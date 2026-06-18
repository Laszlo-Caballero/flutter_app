import 'package:app_machin/components/IconNavBar.dart';
import 'package:app_machin/pages/AnalyzePage.dart';
import 'package:app_machin/pages/GaleryPage.dart';
import 'package:app_machin/pages/HistoryPage.dart';
import 'package:app_machin/pages/HomePage.dart';
import 'package:app_machin/pages/SettingsPage.dart';
import 'package:app_machin/providers/RouteProvider.dart';
import 'package:app_machin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Mainlayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainLayout();
}

class _MainLayout extends State<Mainlayout> {
  Widget _getCurrentPage(String currentRoute) {
    switch (currentRoute) {
      case "/":
        return HomePage();
      case "/galery":
        return Galerypage();
      case "/history":
        return Historypage();
      case "/settings":
        return Settingspage();
      case "/analyze":
        return const AnalyzePage();
      default:
        return HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<Routeprovider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.remove_red_eye_rounded, color: Colors.white),
            SizedBox(width: 12),
            const Text(
              "AI VISUAL SHOPPER",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.blue,
        actionsPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        toolbarHeight: 104,
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Puedes cambiar el tipo de animación aquí
          return FadeTransition(opacity: animation, child: child);
          // O usar SlideTransition:
          // return SlideTransition(
          //   position: Tween<Offset>(
          //     begin: Offset(1.0, 0.0),
          //     end: Offset.zero,
          //   ).animate(animation),
          //   child: child,
          // );
        },
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _getCurrentPage(routeProvider.currentRoute),
        ), // Usa widget.body en lugar de body
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.only(bottom: 24, top: 12, right: 12, left: 12),
        color: Colors.white,
        height: 96,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Iconnavbar(
              iconNav: Icons.center_focus_strong,
              title: "Analizar",
              route: "/",
              currentRoute: routeProvider.currentRoute,
              onTap: () => routeProvider.navigateTo('/'),
            ),
            Iconnavbar(
              iconNav: Icons.photo_library_outlined,
              title: "Galería",
              route: "/galery",
              currentRoute: routeProvider.currentRoute,
              onTap: () => routeProvider.navigateTo('/galery'),
            ),
            Iconnavbar(
              iconNav: Icons.history,
              title: "Historial",
              route: "/history",
              currentRoute: routeProvider.currentRoute,
              onTap: () => routeProvider.navigateTo('/history'),
            ),
            Iconnavbar(
              iconNav: Icons.settings,
              title: "Ajustes",
              route: "/settings",
              currentRoute: routeProvider.currentRoute,
              onTap: () => routeProvider.navigateTo('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}
