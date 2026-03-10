part of 'wheel.dart';

/// Draws a slice of a circle. The slice's arc starts at the right (3 o'clock)
/// and moves clockwise as far as specified by angle.
class _CircleSlicePainter extends CustomPainter {
  final Color fillColor;
  final Gradient? gradient;
  final Color? strokeColor;
  final double strokeWidth;
  final Gradient? borderGradient;
  final double angle;

  const _CircleSlicePainter({
    required this.fillColor,
    this.gradient,
    this.strokeColor,
    this.strokeWidth = 1,
    this.borderGradient,
    this.angle = _math.pi / 2,
  }) : assert(angle > 0 && angle < 2 * _math.pi);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = _math.min(size.width, size.height);
    final path = _CircleSlice.buildSlicePath(radius, angle);

    // fill slice area
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromCircle(center: Offset.zero, radius: radius),
      );
    }

    canvas.drawPath(path, paint);

    // draw slice border
    if (strokeWidth > 0) {
      if (borderGradient != null) {
        final borderPaint = Paint()
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        // Create a rect where the left edge is at x=0 (center of wheel)
        // and right edge is at x=radius (outer edge of wheel).
        // This makes Alignment.centerLeft map to the center of the wheel
        // and Alignment.centerRight map to the outer edge.
        borderPaint.shader = borderGradient!.createShader(
          Rect.fromPoints(Offset(0, -radius), Offset(radius, radius)),
        );

        // Draw the leading edge of the slice
        final linePath = Path()
          ..moveTo(0, 0)
          ..lineTo(radius, 0);

        canvas.drawPath(linePath, borderPaint);

        // Draw the trailing edge of the slice by rotating the canvas.
        // Rotating the canvas ensures the shader maps exactly the same way
        // (from center to edge) as it did for the leading edge!
        canvas.save();
        canvas.rotate(angle);
        canvas.drawPath(linePath, borderPaint);
        canvas.restore();
      } else {
        final borderPaint = Paint()
          ..color = strokeColor ?? Colors.transparent
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

        canvas.drawPath(
          path,
          borderPaint,
        );

        final outerArcPaint = Paint()
          ..color = strokeColor ?? Colors.transparent
          ..strokeWidth = strokeWidth * 2
          ..style = PaintingStyle.stroke;

        canvas.drawPath(
          Path()
            ..arcTo(
                Rect.fromCircle(
                  center: Offset(0, 0),
                  radius: radius,
                ),
                0,
                angle,
                false),
          outerArcPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CircleSlicePainter oldDelegate) {
    return angle != oldDelegate.angle ||
        fillColor != oldDelegate.fillColor ||
        gradient != oldDelegate.gradient ||
        strokeColor != oldDelegate.strokeColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        borderGradient != oldDelegate.borderGradient;
  }
}
