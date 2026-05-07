// ============================================================
// status_indicator.dart — Connection & AI status widgets
// Smart AI Voice Car Controller
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
import '../providers/app_provider.dart';

class ConnectionBadge extends StatelessWidget {
  final ApiConnectionState state;

  const ConnectionBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final config = _config(state);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusDot(color: config.color, pulse: config.pulse),
          const SizedBox(width: 7),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _config(ApiConnectionState s) {
    switch (s) {
      case ApiConnectionState.connected:
        return _BadgeConfig(AppTheme.neonGreen, 'CONNECTED', false);
      case ApiConnectionState.disconnected:
        return _BadgeConfig(AppTheme.neonRed, 'OFFLINE', false);
      case ApiConnectionState.checking:
        return _BadgeConfig(AppTheme.neonOrange, 'CHECKING...', true);
      case ApiConnectionState.unknown:
        return _BadgeConfig(AppTheme.textMuted, 'NOT TESTED', false);
    }
  }
}

class _BadgeConfig {
  final Color color;
  final String label;
  final bool pulse;
  _BadgeConfig(this.color, this.label, this.pulse);
}

// ─────────────────────────────────────────────────────────────
// Pulsing dot
// ─────────────────────────────────────────────────────────────
class _StatusDot extends StatelessWidget {
  final Color color;
  final bool pulse;

  const _StatusDot({required this.color, required this.pulse});

  @override
  Widget build(BuildContext context) {
    Widget dot = Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
      ),
    );

    if (pulse) {
      dot = dot
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .fade(begin: 0.3, end: 1.0, duration: 700.ms);
    }

    return dot;
  }
}

// ─────────────────────────────────────────────────────────────
// Glowing info card
// ─────────────────────────────────────────────────────────────
class GlowCard extends StatelessWidget {
  final Widget child;
  final List<BoxShadow>? glow;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? borderColor;

  const GlowCard({
    super.key,
    required this.child,
    this.glow,
    this.padding,
    this.borderRadius = 16,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppTheme.darkBorder,
          width: 1,
        ),
        boxShadow: glow ?? AppTheme.cardShadow,
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stat row — label + value
// ─────────────────────────────────────────────────────────────
class StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  const StatRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Confidence bar
// ─────────────────────────────────────────────────────────────
class ConfidenceBar extends StatelessWidget {
  final double confidence;

  const ConfidenceBar({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final pct = (confidence / 100.0).clamp(0.0, 1.0);
    final color = confidence >= 80
        ? AppTheme.neonGreen
        : confidence >= 60
            ? AppTheme.neonCyan
            : AppTheme.neonRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CONFIDENCE',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${confidence.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppTheme.darkBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ).animate().slideX(begin: -1, end: 0, duration: 600.ms, curve: Curves.easeOut),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Voice waveform animation
// ─────────────────────────────────────────────────────────────
class VoiceWaveform extends StatelessWidget {
  final bool active;

  const VoiceWaveform({super.key, this.active = false});

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          9,
          (i) => _Bar(height: 4, color: AppTheme.textMuted, delay: 0),
        ),
      );
    }

    const heights = [10.0, 18.0, 26.0, 20.0, 32.0, 20.0, 26.0, 18.0, 10.0];
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        9,
        (i) => _Bar(
          height: heights[i],
          color: AppTheme.neonCyan,
          delay: i * 80,
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;
  final int delay;

  const _Bar({required this.height, required this.color, required this.delay});

  @override
  Widget build(BuildContext context) {
    Widget bar = Container(
      width: 4,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );

    if (height > 4) {
      bar = bar
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleY(
            begin: 0.3,
            end: 1.0,
            duration: Duration(milliseconds: 600 + delay),
            delay: Duration(milliseconds: delay),
            curve: Curves.easeInOut,
          );
    }

    return bar;
  }
}
