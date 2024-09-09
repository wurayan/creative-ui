import 'package:flutter/material.dart';

///[CustomShapeShadow] creates a customized shape (built by [CustomClipper]) with a list of [BoxShadow] applied to it;
class CustomShapeShadow extends StatelessWidget {
  final CustomClipper<Path> customClipper;
  final List<BoxShadow> boxShadows;
  final Widget child;
  const CustomShapeShadow(
      {super.key,
      required this.customClipper,
      required this.boxShadows,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CustomShadowPainter(
        customClipper: customClipper,
        boxShadows: boxShadows,
      ),
      child: ClipPath(
        clipper: customClipper,
        child: child,
      ),
    );
  }
}

class _CustomShadowPainter extends CustomPainter {
  final CustomClipper<Path> customClipper;
  final List<BoxShadow> boxShadows;

  _CustomShadowPainter({
    required this.customClipper,
    required this.boxShadows,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var boxShadow in boxShadows) {
      final spreadRadius = boxShadow.spreadRadius * 2;
      final spreadSize = Size(
        size.width + spreadRadius,
        size.height + spreadRadius,
      );
      final paint = boxShadow.toPaint();
      final path = customClipper.getClip(spreadSize).shift(
            Offset(boxShadow.offset.dx - boxShadow.spreadRadius,
                boxShadow.offset.dy - boxShadow.spreadRadius),
          );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
