// ============================================================
// mic_button.dart — Animated pulsing microphone button
// Smart AI Voice Car Controller
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class MicButton extends StatefulWidget {
  final bool isListening;
  final bool isProcessing;
  final VoidCallback onTap;
  final double size;

  const MicButton({
    super.key,
    required this.isListening,
    required this.isProcessing,
    required this.onTap,
    this.size = 100,
  });

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MicButton old) {
    super.didUpdateWidget(old);
    if (widget.isListening && !old.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && old.isListening) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return GestureDetector(
      onTap: widget.isProcessing ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          final scale = widget.isListening ? _pulseAnim.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: SizedBox(
          width: s + 40,
          height: s + 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Outer glow ring ───────────────────────────
              if (widget.isListening)
                Container(
                  width: s + 36,
                  height: s + 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.neonCyan.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.2, 1.2),
                      duration: 1200.ms,
                      curve: Curves.easeOut,
                    )
                    .fade(begin: 0.8, end: 0.0, duration: 1200.ms),

              // ── Middle ring ───────────────────────────────
              if (widget.isListening)
                Container(
                  width: s + 20,
                  height: s + 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.neonCyan.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1.15, 1.15),
                      delay: 200.ms,
                      duration: 1200.ms,
                      curve: Curves.easeOut,
                    )
                    .fade(begin: 0.6, end: 0.0, duration: 1200.ms, delay: 200.ms),

              // ── Main button ───────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.isListening
                      ? const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : widget.isProcessing
                          ? const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF0F2744), Color(0xFF0D1F3C)],
                            ),
                  border: Border.all(
                    color: widget.isListening
                        ? AppTheme.neonCyan
                        : widget.isProcessing
                            ? AppTheme.neonPurple
                            : AppTheme.darkBorder,
                    width: 1.5,
                  ),
                  boxShadow: widget.isListening
                      ? AppTheme.cyanGlow(1.2)
                      : widget.isProcessing
                          ? AppTheme.purpleGlow(0.8)
                          : [],
                ),
                child: _buildIcon(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIcon() {
    if (widget.isProcessing) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    return Center(
      child: Icon(
        widget.isListening ? Icons.mic : Icons.mic_none_rounded,
        color: widget.isListening ? Colors.white : AppTheme.neonCyan,
        size: widget.size * 0.42,
      ),
    );
  }
}
