import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/participant.dart';
import '../theme/app_palette.dart';

const List<Color> kWheelColors = [
  Color(0xFFFFD700), // Amarillo
  Color(0xFFFF8C00), // Naranja
  Color(0xFFFF3B30), // Rojo
  Color(0xFFFF69B4), // Rosa
  Color(0xFF9B59B6), // Morado
  Color(0xFF2980B9), // Azul oscuro
  Color(0xFF00BFFF), // Celeste
  Color(0xFF00CED1), // Cyan
  Color(0xFF2ECC71), // Verde
  Color(0xFFA5DF00), // Verde claro
];

class RouletteWheel extends StatelessWidget {
  final List<Participant> participants;
  final List<double> normalizedWeights;
  final double rotationAngle;

  const RouletteWheel({
    super.key,
    required this.participants,
    required this.normalizedWeights,
    required this.rotationAngle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: rotationAngle,
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: _WheelPainter(
                      participants: participants,
                      weights: normalizedWeights,
                    ),
                  ),
                ),
                // Indicator arrow at top
                Positioned(
                  top: 0,
                  child: CustomPaint(
                    size: const Size(28, 32),
                    painter: _ArrowPainter(),
                  ),
                ),
                // Center circle
                Container(
                  width: size * 0.13,
                  height: size * 0.13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppPalette.background,
                    border: Border.all(
                      color: AppPalette.cyan.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.cyan.withValues(alpha: 0.2),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<Participant> participants;
  final List<double> weights;

  _WheelPainter({required this.participants, required this.weights});

  @override
  void paint(Canvas canvas, Size size) {
    if (participants.isEmpty || weights.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;

    final borderPaint = Paint()
      ..color = AppPalette.background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < participants.length; i++) {
      final sweepAngle = weights[i] * 2 * math.pi;

      final paint = Paint()
        ..color = kWheelColors[i % kWheelColors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);

      _drawText(
        canvas,
        center,
        radius,
        startAngle,
        sweepAngle,
        participants[i].name,
      );

      startAngle += sweepAngle;
    }

    // Outer ring
    final outerRing = Paint()
      ..color = AppPalette.cyan.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 1.5, outerRing);
  }

  void _drawText(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    String text,
  ) {
    final midAngle = startAngle + sweepAngle / 2;

    final arcLength = sweepAngle * radius;
    if (arcLength < 20) return;

    final maxTextWidth = radius * 0.55;
    double fontSize = (arcLength * 0.35).clamp(8.0, 16.0);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          shadows: const [
            Shadow(color: Colors.black54, blurRadius: 3),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    );

    textPainter.layout(maxWidth: maxTextWidth);

    canvas.save();
    final textRadius = radius * 0.62;
    final textCenter = Offset(
      center.dx + textRadius * math.cos(midAngle),
      center.dy + textRadius * math.sin(midAngle),
    );

    canvas.translate(textCenter.dx, textCenter.dy);
    canvas.rotate(midAngle + (midAngle.abs() > math.pi / 2 && midAngle.abs() < 3 * math.pi / 2 ? math.pi : 0));

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => true;
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppPalette.cyan
      ..style = PaintingStyle.fill;

    final shadow = Paint()
      ..color = AppPalette.cyan.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
