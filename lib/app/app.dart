import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import 'app_routes.dart';
import 'app_theme.dart';

class PharmaChainApp extends StatelessWidget {
  const PharmaChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
