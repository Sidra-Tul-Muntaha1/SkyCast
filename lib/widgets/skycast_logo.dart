
import 'package:flutter/material.dart';
import '../core/app_constants.dart';

class SkyCastLogo extends StatelessWidget {
  const SkyCastLogo({
    super.key,
    this.size = 76,
    this.showTitle = true,
    this.centered = false,
  });

  final double size;
  final bool showTitle;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final logoIcon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.lightBlue,
            AppConstants.primaryBlue,
            AppConstants.lavender,
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.12,
            right: size * 0.18,
            child: Icon(
              Icons.wb_sunny_rounded,
              size: size * 0.48,
              color: AppConstants.sunshineYellow,
            ),
          ),
          Positioned(
            bottom: size * 0.08,
            left: size * 0.08,
            child: Icon(
              Icons.cloud_rounded,
              size: size * 0.76,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Color(0x33203366),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!showTitle) return logoIcon;

    final title = Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          AppConstants.tagline,
          style: TextStyle(
            fontSize: size * 0.16,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );

    if (centered) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoIcon,
          const SizedBox(height: 20),
          title,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoIcon,
        const SizedBox(width: 14),
        Flexible(child: title),
      ],
    );
  }
}
