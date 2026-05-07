// ============================================================
// home_screen.dart — Main dashboard screen
// Smart AI Voice Car Controller
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/mic_button.dart';
import '../widgets/command_card.dart';
import '../widgets/status_indicator.dart';
import '../widgets/manual_controls.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0 = Voice, 1 = Manual, 2 = History

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AppProvider>();
      await provider.checkConnection();
    });
  }

  // ── Snackbar helper ───────────────────────────────────────
  void _showSnack(String msg, {Color? color, IconData? icon}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: color ?? AppTheme.neonCyan, size: 16),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: AppTheme.darkCard,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        // Show errors as snackbars
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.voiceError.isNotEmpty) {
            _showSnack(provider.voiceError, color: AppTheme.neonRed, icon: Icons.mic_off);
            provider.clearErrors();
          } else if (provider.apiError.isNotEmpty) {
            _showSnack(provider.apiError, color: AppTheme.neonRed, icon: Icons.cloud_off);
            provider.clearErrors();
          }
        });

        return Scaffold(
          backgroundColor: AppTheme.darkBg,
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(provider),
          body: Container(
            decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
            child: SafeArea(
              child: Column(
                children: [
                  // ── Status bar ─────────────────────────────
                  _StatusBar(provider: provider, onRefresh: () async {
                    final ok = await provider.checkConnection();
                    _showSnack(
                      ok ? 'Connected to backend ✓' : 'Cannot reach backend',
                      color: ok ? AppTheme.neonGreen : AppTheme.neonRed,
                      icon: ok ? Icons.check_circle_outline : Icons.error_outline,
                    );
                  }),

                  // ── Tab bar ────────────────────────────────
                  _TabBar(
                    selected: _selectedTab,
                    onTap: (i) => setState(() => _selectedTab = i),
                  ),

                  // ── Tab content ────────────────────────────
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _selectedTab == 0
                          ? _VoiceTab(provider: provider, key: const ValueKey('voice'))
                          : _selectedTab == 1
                              ? _ManualTab(provider: provider, key: const ValueKey('manual'))
                              : _HistoryTab(provider: provider, key: const ValueKey('history')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(AppProvider provider) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_car_filled_rounded, color: AppTheme.neonCyan, size: 20),
          const SizedBox(width: 8),
          Text('SMART CAR AI', style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppTheme.textPrimary)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          tooltip: 'Settings',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Status Bar
// ─────────────────────────────────────────────────────────────
class _StatusBar extends StatelessWidget {
  final AppProvider provider;
  final VoidCallback onRefresh;

  const _StatusBar({required this.provider, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ConnectionBadge(state: provider.connectionState),
          const SizedBox(width: 8),
          if (provider.apiStatus != null) ...[
            _SmallBadge(
              label: 'AI MODEL',
              active: provider.apiStatus!.modelLoaded,
            ),
            const SizedBox(width: 8),
            _SmallBadge(
              label: 'MQTT',
              active: provider.apiStatus!.mqttConnected,
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: provider.connectionState == ApiConnectionState.checking
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppTheme.neonCyan,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final bool active;
  const _SmallBadge({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.neonGreen : AppTheme.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab Bar
// ─────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final int selected;
  final Function(int) onTap;

  const _TabBar({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (Icons.mic_rounded, 'VOICE'),
      (Icons.gamepad_rounded, 'MANUAL'),
      (Icons.history_rounded, 'HISTORY'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final isSelected = i == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.neonCyan.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(tabs[i].$1,
                          size: 14,
                          color: isSelected ? AppTheme.neonCyan : AppTheme.textMuted),
                      const SizedBox(width: 5),
                      Text(
                        tabs[i].$2,
                        style: TextStyle(
                          color: isSelected ? AppTheme.neonCyan : AppTheme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Voice Tab
// ─────────────────────────────────────────────────────────────
class _VoiceTab extends StatelessWidget {
  final AppProvider provider;
  const _VoiceTab({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Language toggle ──────────────────────────────
          _LangToggle(provider: provider),
          const SizedBox(height: 20),

          // ── Voice display card ───────────────────────────
          GlowCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Waveform
                VoiceWaveform(active: provider.isListening),
                const SizedBox(height: 16),

                // Recognized text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _VoiceTextDisplay(provider: provider),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Mic button ───────────────────────────────────
          MicButton(
            isListening: provider.isListening,
            isProcessing: provider.isProcessing,
            onTap: () {
              HapticFeedback.mediumImpact();
              if (provider.isListening) {
                provider.stopListening();
              } else {
                provider.startListening();
              }
            },
            size: 100,
          ),

          const SizedBox(height: 12),
          Text(
            provider.isListening
                ? 'TAP TO STOP'
                : provider.isProcessing
                    ? 'PROCESSING...'
                    : 'TAP TO SPEAK',
            style: TextStyle(
              color: provider.isListening ? AppTheme.neonCyan : AppTheme.textMuted,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 28),

          // ── AI result card ───────────────────────────────
          if (provider.lastPrediction != null)
            CommandResultCard(result: provider.lastPrediction!),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _VoiceTextDisplay extends StatelessWidget {
  final AppProvider provider;
  const _VoiceTextDisplay({required this.provider});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    if (provider.isListening && provider.partialText.isNotEmpty) {
      text = provider.partialText;
      color = AppTheme.neonCyan.withValues(alpha: 0.7);
    } else if (provider.recognizedText.isNotEmpty) {
      text = provider.recognizedText;
      color = AppTheme.textPrimary;
    } else if (provider.isListening) {
      text = provider.isArabic ? 'جاري الاستماع...' : 'Listening...';
      color = AppTheme.textMuted;
    } else {
      text = provider.isArabic
          ? 'قل أمرك مثل: "امشي قدام"'
          : 'Say a command like "go forward"';
      color = AppTheme.textMuted;
    }

    return Text(
      text,
      key: ValueKey(text),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: 17,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
    );
  }
}

class _LangToggle extends StatelessWidget {
  final AppProvider provider;
  const _LangToggle({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangChip(
            label: 'العربية',
            flag: '🇪🇬',
            selected: provider.isArabic,
            onTap: () => provider.setLocale(AppConstants.localeArabic),
          ),
          const SizedBox(width: 4),
          _LangChip(
            label: 'English',
            flag: '🇺🇸',
            selected: !provider.isArabic,
            onTap: () => provider.setLocale(AppConstants.localeEnglish),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  const _LangChip({required this.label, required this.flag, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.neonCyan.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: selected ? Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.4)) : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
              color: selected ? AppTheme.neonCyan : AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Manual Tab
// ─────────────────────────────────────────────────────────────
class _ManualTab extends StatelessWidget {
  final AppProvider provider;
  const _ManualTab({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlowCard(
            glow: AppTheme.cyanGlow(0.3),
            borderColor: AppTheme.neonCyan.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'MANUAL CONTROL',
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    color: AppTheme.neonCyan,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Send commands directly to the car via MQTT',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                ManualControls(
                  onCommand: (cmd) {
                    HapticFeedback.lightImpact();
                    provider.sendManualCommand(cmd);
                  },
                  enabled: !provider.isProcessing,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.05, end: 0),

          const SizedBox(height: 16),

          if (provider.lastPrediction != null)
            CommandResultCard(result: provider.lastPrediction!),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// History Tab
// ─────────────────────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final AppProvider provider;
  const _HistoryTab({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final history = provider.history;

    return Column(
      children: [
        // Header + clear
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${history.length} COMMANDS',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, letterSpacing: 1),
              ),
              const Spacer(),
              if (history.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _confirmClear(context, provider),
                  icon: const Icon(Icons.delete_outline, size: 14),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.neonRed,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ),

        if (history.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history_rounded, color: AppTheme.textMuted, size: 48),
                  const SizedBox(height: 12),
                  const Text('No commands yet', style: TextStyle(color: AppTheme.textMuted, fontSize: 15)),
                  const SizedBox(height: 6),
                  const Text('Use voice or manual controls to send commands',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = history[i];
                final cmdColor = _cmdColor(item.command);
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cmdColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cmdColor.withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Text(
                            AppConstants.commandIcons[item.command] ?? '?',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.voiceText,
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(item.command,
                                    style: TextStyle(color: cmdColor, fontSize: 11, fontWeight: FontWeight.w700)),
                                if (item.confidence != null) ...[
                                  const Text(' · ', style: TextStyle(color: AppTheme.textMuted)),
                                  Text('${item.confidence!.toStringAsFixed(0)}%',
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(
                            item.success ? Icons.check_circle_outline : Icons.cancel_outlined,
                            color: item.success ? AppTheme.neonGreen : AppTheme.neonRed,
                            size: 16,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: i * 40));
              },
            ),
          ),
      ],
    );
  }

  Color _cmdColor(String cmd) {
    switch (cmd) {
      case 'FORWARD': return AppTheme.neonCyan;
      case 'BACKWARD': return AppTheme.neonPurple;
      case 'LEFT': return AppTheme.neonBlue;
      case 'RIGHT': return const Color(0xFF00BFFF);
      case 'STOP': return AppTheme.neonRed;
      default: return AppTheme.textSecondary;
    }
  }

  Future<void> _confirmClear(BuildContext context, AppProvider provider) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear History', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Delete all command history?', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: AppTheme.neonRed)),
          ),
        ],
      ),
    );
    if (ok == true) provider.clearHistory();
  }
}
