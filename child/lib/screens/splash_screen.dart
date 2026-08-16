import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.nights_stay_rounded, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'IbadahKu',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            Text(
              'Monitoring ibadah harian',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
