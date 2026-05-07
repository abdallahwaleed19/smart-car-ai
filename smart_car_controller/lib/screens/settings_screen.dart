// ============================================================
// settings_screen.dart — App configuration screen
// Smart AI Voice Car Controller
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/status_indicator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;
  bool _testingConnection = false;
  String? _testResult;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _urlController = TextEditingController(text: provider.apiUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    await context.read<AppProvider>().updateApiUrl(url);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('API URL saved ✓'),
          backgroundColor: AppTheme.darkCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _testingConnection = true;
      _testResult = null;
      _testSuccess = null;
    });

    await context.read<AppProvider>().updateApiUrl(_urlController.text.trim());
    final ok = await context.read<AppProvider>().checkConnection();

    if (mounted) {
      setState(() {
        _testingConnection = false;
        _testSuccess = ok;
        _testResult = ok
            ? 'Connected successfully! Backend is online.'
            : context.read<AppProvider>().apiError.isNotEmpty
                ? context.read<AppProvider>().apiError
                : 'Connection failed. Check the URL and server status.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.darkBg,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('SETTINGS'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.neonCyan, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── API Config section ─────────────────────
                  _SectionHeader(label: 'API CONFIGURATION', icon: Icons.cloud_rounded),
                  const SizedBox(height: 12),

                  GlowCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Backend URL',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _urlController,
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'https://your-ngrok-url.ngrok-free.app',
                            prefixIcon: const Icon(Icons.link_rounded, color: AppTheme.neonCyan, size: 18),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear, color: AppTheme.textMuted, size: 16),
                              onPressed: () => _urlController.clear(),
                            ),
                          ),
                          keyboardType: TextInputType.url,
                          autocorrect: false,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                label: 'SAVE URL',
                                icon: Icons.save_outlined,
                                color: AppTheme.neonCyan,
                                onTap: _saveUrl,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ActionButton(
                                label: _testingConnection ? 'TESTING...' : 'TEST CONNECTION',
                                icon: Icons.wifi_find_rounded,
                                color: AppTheme.neonGreen,
                                onTap: _testingConnection ? null : _testConnection,
                                loading: _testingConnection,
                              ),
                            ),
                          ],
                        ),

                        // Test result
                        if (_testResult != null) ...[
                          const SizedBox(height: 10),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: (_testSuccess == true ? AppTheme.neonGreen : AppTheme.neonRed)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: (_testSuccess == true ? AppTheme.neonGreen : AppTheme.neonRed)
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _testSuccess == true ? Icons.check_circle_outline : Icons.error_outline,
                                  color: _testSuccess == true ? AppTheme.neonGreen : AppTheme.neonRed,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _testResult!,
                                    style: TextStyle(
                                      color: _testSuccess == true ? AppTheme.neonGreen : AppTheme.neonRed,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 300.ms),
                        ],
                      ],
                    ),
                  ),

                  // ── Server Status section ──────────────────
                  if (provider.apiStatus != null) ...[
                    const SizedBox(height: 20),
                    _SectionHeader(label: 'SERVER STATUS', icon: Icons.monitor_heart_outlined),
                    const SizedBox(height: 12),
                    GlowCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          StatRow(
                            label: 'Connection',
                            value: provider.isConnected ? 'Online' : 'Offline',
                            valueColor: provider.isConnected ? AppTheme.neonGreen : AppTheme.neonRed,
                          ),
                          StatRow(
                            label: 'AI Model',
                            value: provider.apiStatus!.modelLoaded ? 'Loaded ✓' : 'Not loaded ✗',
                            valueColor: provider.apiStatus!.modelLoaded ? AppTheme.neonGreen : AppTheme.neonRed,
                          ),
                          StatRow(
                            label: 'MQTT Broker',
                            value: provider.apiStatus!.mqttConnected ? 'Connected ✓' : 'Disconnected ✗',
                            valueColor: provider.apiStatus!.mqttConnected ? AppTheme.neonGreen : AppTheme.neonRed,
                          ),
                          StatRow(
                            label: 'Confidence Threshold',
                            value: '${provider.apiStatus!.threshold.toStringAsFixed(0)}%',
                          ),
                          if (provider.apiStatus!.mqttStats != null) ...[
                            const Divider(color: AppTheme.darkBorder, height: 20),
                            StatRow(
                              label: 'Commands Sent',
                              value: '${provider.apiStatus!.mqttStats!.sent}',
                              valueColor: AppTheme.neonCyan,
                            ),
                            StatRow(
                              label: 'Commands Failed',
                              value: '${provider.apiStatus!.mqttStats!.failed}',
                              valueColor: provider.apiStatus!.mqttStats!.failed > 0
                                  ? AppTheme.neonRed
                                  : AppTheme.textSecondary,
                            ),
                            if (provider.apiStatus!.mqttStats!.last != null)
                              StatRow(
                                label: 'Last Command',
                                value: '${provider.apiStatus!.mqttStats!.last} (${provider.apiStatus!.mqttStats!.lastTime ?? ''})',
                                valueColor: AppTheme.neonCyan,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // ── Appearance section ─────────────────────
                  const SizedBox(height: 20),
                  _SectionHeader(label: 'APPEARANCE', icon: Icons.palette_outlined),
                  const SizedBox(height: 12),

                  GlowCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.dark_mode_outlined, color: AppTheme.neonCyan, size: 20),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Dark Mode', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                                  Text('Futuristic dark theme', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: provider.isDarkMode,
                              onChanged: (_) => provider.toggleTheme(),
                              activeColor: AppTheme.neonCyan,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Language section ───────────────────────
                  const SizedBox(height: 20),
                  _SectionHeader(label: 'VOICE LANGUAGE', icon: Icons.language_rounded),
                  const SizedBox(height: 12),

                  GlowCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _LangOption(
                          flag: '🇪🇬',
                          label: 'Arabic (Egypt)',
                          subtitle: 'ar-EG',
                          selected: provider.isArabic,
                          onTap: () => provider.setLocale(AppConstants.localeArabic),
                        ),
                        const Divider(color: AppTheme.darkBorder, height: 16),
                        _LangOption(
                          flag: '🇺🇸',
                          label: 'English (US)',
                          subtitle: 'en-US',
                          selected: !provider.isArabic,
                          onTap: () => provider.setLocale(AppConstants.localeEnglish),
                        ),
                      ],
                    ),
                  ),

                  // ── Commands reference ─────────────────────
                  const SizedBox(height: 20),
                  _SectionHeader(label: 'COMMAND REFERENCE', icon: Icons.info_outline_rounded),
                  const SizedBox(height: 12),

                  GlowCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: AppConstants.commandIcons.entries.map((e) {
                        final arabic = AppConstants.commandArabicLabels[e.key] ?? '';
                        final english = AppConstants.commandLabels[e.key] ?? '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Text(e.value, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 12),
                              Text(e.key,
                                  style: const TextStyle(
                                      color: AppTheme.neonCyan, fontWeight: FontWeight.w700, fontSize: 13)),
                              const Spacer(),
                              Text('$arabic / $english',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // ── About section ──────────────────────────
                  const SizedBox(height: 20),
                  _SectionHeader(label: 'ABOUT', icon: Icons.info_rounded),
                  const SizedBox(height: 12),

                  GlowCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        StatRow(label: 'App Name', value: AppConstants.appName),
                        StatRow(label: 'Version', value: AppConstants.appVersion),
                        StatRow(label: 'Architecture', value: 'Flask → MQTT → ESP8266'),
                        StatRow(label: 'Voice Locale', value: provider.selectedLocale),
                        StatRow(label: 'State Manager', value: 'Provider'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.neonCyan, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.neonCyan,
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: AppTheme.darkBorder)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Action button
// ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(onTap != null ? 0.4 : 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
              )
            else
              Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: onTap != null ? color : color.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Language option row
// ─────────────────────────────────────────────────────────────
class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption({
    required this.flag,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppTheme.neonCyan : Colors.transparent,
              border: Border.all(
                color: selected ? AppTheme.neonCyan : AppTheme.darkBorder,
                width: 1.5,
              ),
              boxShadow: selected ? AppTheme.cyanGlow(0.5) : [],
            ),
            child: selected
                ? const Icon(Icons.check, color: AppTheme.darkBg, size: 12)
                : null,
          ),
        ],
      ),
    );
  }
}
