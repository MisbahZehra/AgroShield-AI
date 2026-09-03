import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../../providers/app_providers.dart';

class AgroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const AgroCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}

class AgroButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool danger;
  final bool outline;

  const AgroButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.danger = false,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outline) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: danger ? AppColors.danger : AppColors.primary),
          foregroundColor: danger ? AppColors.danger : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _label(),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: danger ? AppColors.danger : AppColors.primary,
      ),
      child: _label(),
    );
  }

  Widget _label() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(label),
        ],
      );
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class ConfidenceIndicator extends StatelessWidget {
  final double value;

  const ConfidenceIndicator({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = value >= 0.7
        ? AppColors.primary
        : value >= 0.3
            ? AppColors.warning
            : AppColors.danger;
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              value: value.clamp(0, 1),
              strokeWidth: 7,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            '${(value * 100).toStringAsFixed(1)}%',
            style:
                const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class HealthRing extends StatelessWidget {
  final int percent;
  final String status;

  const HealthRing({super.key, required this.percent, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'good'
        ? AppColors.primary
        : status == 'moderate'
            ? AppColors.warning
            : AppColors.danger;
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            '$percent%',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (severity) {
      'high' => (AppColors.danger, AppColors.dangerLight),
      'moderate' => (AppColors.warning, AppColors.warningLight),
      _ => (AppColors.primary, AppColors.successLight),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
            color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class RiskDot extends StatelessWidget {
  final String level;

  const RiskDot({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      'high' => AppColors.danger,
      'medium' => AppColors.warning,
      _ => AppColors.primary,
    };
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              AgroButton(
                  label: 'Retry', icon: Icons.refresh, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class AudioButton extends ConsumerWidget {
  final String text;

  const AudioButton({super.key, required this.text});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speaking = ref.watch(_speakingProvider);
    return IconButton(
      tooltip: 'Listen',
      iconSize: 26,
      onPressed: () async {
        final tts = ref.read(ttsServiceProvider);
        if (speaking) {
          await tts.stop();
          ref.read(_speakingProvider.notifier).state = false;
        } else {
          ref.read(_speakingProvider.notifier).state = true;
          await tts.speak(text);
          ref.read(_speakingProvider.notifier).state = false;
        }
      },
      icon: Icon(
        speaking ? Icons.stop_circle_outlined : Icons.volume_up,
        color: AppColors.primary,
      ),
    );
  }
}

final _speakingProvider = StateProvider<bool>((ref) => false);

class OfflineBanner extends StatelessWidget {
  final bool online;

  const OfflineBanner({super.key, required this.online});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: online ? AppColors.primaryLight : AppColors.warningLight,
      child: Row(
        children: [
          Icon(
            online ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: online ? AppColors.primary : AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              online
                  ? 'Online - Offline AI: diagnosis runs on your device'
                  : 'Offline - AI diagnosis still runs on your device',
              style: TextStyle(
                fontSize: 12,
                color: online ? AppColors.primaryDark : AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
