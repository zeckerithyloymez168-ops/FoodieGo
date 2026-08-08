import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NetworkImageBox extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const NetworkImageBox({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.emerald50,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.emerald600,
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => Container(
          width: width,
          height: height,
          color: AppColors.emerald50,
          alignment: Alignment.center,
          child: const Icon(Icons.restaurant, color: AppColors.emerald600),
        ),
      ),
    );
  }
}
