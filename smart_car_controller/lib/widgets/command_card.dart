// ============================================================
// command_card.dart — AI result display card
// Smart AI Voice Car Controller
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prediction_model.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'status_indicator.dart';

class CommandResultCard extends StatelessWidget {
  final PredictionResult result;
  const CommandResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final cmdColor = _commandColor(result.command);
    final icon = AppConstants.commandIcons[result.command] ?? '❓';

    return GlowCard(
      glow: [
        BoxShadow(color: cmdColor.withValues(alpha: 0.25), blurRadius: 24, spreadRadius: 1),
        ...AppTheme.cardShadow,
      ],
      borderColor: cmdColor.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cmdColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cmdColor.withValues(alpha: 0.3)),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.command,
                      style: GoogleFonts.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: cmdColor,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      result.intent.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              _MqttBadge(sent: result.mqttSent),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.darkBorder),
          const SizedBox(height: 12),

          // Voice input
          _LabeledField(label: 'VOICE INPUT', value: result.input),
          const SizedBox(height: 12),

          // Confidence bar
          if (result.confidence != null) ...[
            ConfidenceBar(confidence: result.confidence!),
            const SizedBox(height: 12),
          ],

          // Stats
          Row(
            children: [
              Expanded(
                child: _MiniStat(label: 'INTENT', value: result.intent, color: AppTheme.neonCyan),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'TO CAR',
                  value: result.mqttSent ? 'SENT ✓' : 'FAILED ✗',
                  color: result.mqttSent ? AppTheme.neonGreen : AppTheme.neonRed,
                ),
              ),
            ],
          ),

          // Low confidence warning
          if (result.lowConfidence) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.neonOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.neonOrange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppTheme.neonOrange, size: 14),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Low confidence — STOP sent as safety measure',
                      style: TextStyle(color: AppTheme.neonOrange, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms);
  }

  Color _commandColor(String cmd) {
    switch (cmd) {
      case 'FORWARD': return AppTheme.neonCyan;
      case 'BACKWARD': return AppTheme.neonPurple;
      case 'LEFT': return AppTheme.neonBlue;
      case 'RIGHT': return const Color(0xFF00BFFF);
      case 'STOP': return AppTheme.neonRed;
      default: return AppTheme.textSecondary;
    }
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String value;
  const _LabeledField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MqttBadge extends StatelessWidget {
  final bool sent;
  const _MqttBadge({required this.sent});

  @override
  Widget build(BuildContext context) {
    final color = sent ? AppTheme.neonGreen : AppTheme.neonRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(sent ? Icons.wifi_tethering : Icons.wifi_off_rounded, color: color, size: 12),
          const SizedBox(width: 4),
          Text('MQTT', style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
