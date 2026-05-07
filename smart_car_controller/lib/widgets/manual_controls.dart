// ============================================================
// manual_controls.dart — D-pad manual control buttons
// Smart AI Voice Car Controller
// ============================================================

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ManualControls extends StatelessWidget {
  final Function(String command) onCommand;
  final bool enabled;

  const ManualControls({
    super.key,
    required this.onCommand,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Forward
        _DpadButton(
          icon: Icons.keyboard_arrow_up_rounded,
          label: 'FWD',
          color: AppTheme.neonCyan,
          command: 'FORWARD',
          onTap: enabled ? onCommand : null,
        ),
        const SizedBox(height: 6),
        // Left / Stop / Right
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DpadButton(
              icon: Icons.keyboard_arrow_left_rounded,
              label: 'LEFT',
              color: AppTheme.neonBlue,
              command: 'LEFT',
              onTap: enabled ? onCommand : null,
            ),
            const SizedBox(width: 6),
            _StopButton(onTap: enabled ? onCommand : null),
            const SizedBox(width: 6),
            _DpadButton(
              icon: Icons.keyboard_arrow_right_rounded,
              label: 'RIGHT',
              color: const Color(0xFF00BFFF),
              command: 'RIGHT',
              onTap: enabled ? onCommand : null,
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Backward
        _DpadButton(
          icon: Icons.keyboard_arrow_down_rounded,
          label: 'BACK',
          color: AppTheme.neonPurple,
          command: 'BACKWARD',
          onTap: enabled ? onCommand : null,
        ),
      ],
    );
  }
}

class _DpadButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String command;
  final Function(String)? onTap;

  const _DpadButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.command,
    this.onTap,
  });

  @override
  State<_DpadButton> createState() => _DpadButtonState();
}

class _DpadButtonState extends State<_DpadButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call(widget.command);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: _pressed
              ? widget.color.withOpacity(0.25)
              : widget.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _pressed
                ? widget.color
                : widget.color.withOpacity(0.3),
            width: _pressed ? 1.5 : 1,
          ),
          boxShadow: _pressed
              ? [BoxShadow(color: widget.color.withOpacity(0.4), blurRadius: 16)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: widget.color, size: 28),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.color,
                fontSize: 9,
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

class _StopButton extends StatefulWidget {
  final Function(String)? onTap;
  const _StopButton({this.onTap});

  @override
  State<_StopButton> createState() => _StopButtonState();
}

class _StopButtonState extends State<_StopButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call('STOP');
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: _pressed
              ? AppTheme.neonRed.withOpacity(0.3)
              : AppTheme.neonRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _pressed ? AppTheme.neonRed : AppTheme.neonRed.withOpacity(0.4),
            width: _pressed ? 1.5 : 1,
          ),
          boxShadow: _pressed
              ? [BoxShadow(color: AppTheme.neonRed.withOpacity(0.5), blurRadius: 20)]
              : [],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stop_rounded, color: AppTheme.neonRed, size: 28),
            Text(
              'STOP',
              style: TextStyle(
                color: AppTheme.neonRed,
                fontSize: 9,
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
