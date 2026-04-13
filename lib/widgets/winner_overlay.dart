import 'package:flutter/material.dart';
import '../models/participant.dart';
import '../theme/app_palette.dart';

class WinnerOverlay extends StatefulWidget {
  final String winnerName;
  final AppMode mode;
  final Team? assignedTeam;
  final VoidCallback onPrimary;
  final VoidCallback onClose;

  const WinnerOverlay({
    super.key,
    required this.winnerName,
    required this.mode,
    this.assignedTeam,
    required this.onPrimary,
    required this.onClose,
  });

  @override
  State<WinnerOverlay> createState() => _WinnerOverlayState();
}

class _WinnerOverlayState extends State<WinnerOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOut,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );
    _introController.forward().then((_) {
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isTeamMode => widget.mode == AppMode.teams;

  @override
  Widget build(BuildContext context) {
    final team = widget.assignedTeam;
    final themeColor = _isTeamMode && team != null ? team.color : AppPalette.cyan;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
                    constraints: const BoxConstraints(maxWidth: 380),
                    decoration: BoxDecoration(
                      color: AppPalette.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: themeColor.withValues(alpha: 0.3 + (_pulseAnimation.value * 0.5)),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.15 + (_pulseAnimation.value * 0.3)),
                          blurRadius: 40 + (_pulseAnimation.value * 20),
                          spreadRadius: 2 + (_pulseAnimation.value * 8),
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isTeamMode ? '🏆' : '🎉',
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isTeamMode ? 'SELECCIONADO' : '¡GANADOR!',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.muted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: _isTeamMode && team != null
                            ? [
                                team.color,
                                team.color.withValues(alpha: 0.7),
                              ]
                            : [
                                AppPalette.cyan,
                                AppPalette.blue,
                              ],
                      ).createShader(bounds),
                      child: Text(
                        widget.winnerName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.white54,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isTeamMode && team != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: team.color.withValues(alpha: 0.12),
                          border: Border.all(
                            color: team.color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: team.color,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              team.name,
                              style: TextStyle(
                                color: team.color,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: _NeonButton(
                        label: _isTeamMode ? 'Continuar' : 'Descartar y continuar',
                        color: themeColor,
                        onPressed: widget.onPrimary,
                      ),
                    ),
                    if (!_isTeamMode) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: widget.onClose,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.07),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Cerrar',
                            style: TextStyle(
                              color: AppPalette.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NeonButton extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback onPressed;

  const _NeonButton({
    required this.label,
    this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppPalette.cyan;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [c, c.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppPalette.background,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}