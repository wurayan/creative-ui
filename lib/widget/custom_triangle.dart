import 'dart:math';
import 'package:creative_app/widget/custom_shape_shadow.dart';
import 'package:flutter/material.dart';

///Defines the direction the triangle is "pointing", which means, the oposite of
///the base of the Triangle.
enum TriangleDirection {
  top,
  right,
  bottom,
  left,
  ;

  /// Determines whether the triangle is oriented horizontally or vertically.
  String get orientation =>
      this == TriangleDirection.top || this == TriangleDirection.bottom
          ? "vertical"
          : "horizontal";
}

///Creates a Triangle that fills the space of its [child].
///
/// - If [child] is a Container, the triangle's Base will match the width or height of the container,
/// depending on the triangle's orientation.
/// - If [child] is another widget, the triangle will clip the widget;
/// - If [borderRadius] is provided and greater than 0, the triangle will have rounded corners.
class CustomTriangle extends StatelessWidget {
  final TriangleDirection triangleDirection;
  final List<BoxShadow> boxShadows;
  final Widget child;
  final double? borderRadius;

  CustomTriangle({
    super.key,
    required this.triangleDirection,
    required this.child,
    List<BoxShadow>? boxShadows,
    this.borderRadius,
  }) : boxShadows = boxShadows ?? [];

  @override
  Widget build(BuildContext context) {
    return CustomShapeShadow(
      customClipper: _CustomTriangleClipper(
          triangleDirection: triangleDirection, borderRadius: borderRadius),
      boxShadows: boxShadows,
      child: child,
    );
  }
}

///Draws the triangle using the triangle direction, if [borderRadius] is `null` or `0.0`
///the triangle is drawn without rounded corners;
class _CustomTriangleClipper extends CustomClipper<Path> {
  ///The direction the triangle is pointing;
  final TriangleDirection triangleDirection;

  ///The Radius used to build the rounded corners;
  final double? borderRadius;

  _CustomTriangleClipper({
    required this.triangleDirection,
    this.borderRadius,
  });

  @override
  Path getClip(Size size) {
    return borderRadius == null
        ? _triangleBuilder(Path(), size)
        : _roundedTriangleBuilder(Path(), size, borderRadius!);
  }

  ///Builds the normal Isosceles Triangle;
  Path _triangleBuilder(Path path, Size size) {
    switch (triangleDirection) {
      case TriangleDirection.right:
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        break;
      case TriangleDirection.bottom:
        path.lineTo(size.width, 0);
        path.lineTo(size.width / 2, size.height);
        break;
      case TriangleDirection.left:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height / 2);
        break;
      default:
        path.moveTo(0, size.height);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        break;
    }
    return path;
  }

  ///Builds an isosceles triangle with rounded corners;
  Path _roundedTriangleBuilder(Path path, Size size, double radius) {
    double width = size.width;
    double height = size.height;

    ///Since we're building an Isosceles Triangle the sides (not counting the base) will
    ///always be equal;
    double triangleSide = sqrt(pow((width / 2), 2) + pow(height, 2));

    ///triangleSemiperimeter is half the sum of all triangle sides;
    double triangleSemiperimeter = (triangleSide * 2 + width) / 2;
    double triangleArea = (width * height) / 2;

    ///The maximum radius possible for the biggest circle inside the triangle;
    double maxRadius1 = triangleArea / triangleSemiperimeter;

    ///The maximum possible radius taking the height and width into account;
    double maxRadius2 = min(size.width / 2, size.height / 2);

    if (radius > min(maxRadius1, maxRadius2)) {
      radius = min(maxRadius1, maxRadius2);
    }

    path = _triangleStart(size, radius, path, triangleDirection);
    path = _triangleTip(size, radius, path, triangleDirection);
    path = _triangleEnd(size, radius, path, triangleDirection);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

/// Constructs the tip of an isosceles triangle with rounded edges.
Path _triangleTip(
  Size size,
  double radius,
  Path path,
  TriangleDirection triangleDirection,
) {
  /// Determines the base and height of the triangle based on its orientation (horizontal or vertical).
  double base =
      triangleDirection.orientation == "vertical" ? size.width : size.height;
  double height =
      triangleDirection.orientation == "vertical" ? size.height : size.width;

  /// Applies the formula θ = arctan(2h/b) to calculate the angle adjacent to the base of the triangle in radians.
  /// This angle defines the start and end points of the tip's curvature.
  double baseRad = atan(height / (base / 2));

  /// Converts baseRad (in radians) to degrees.
  double baseAngle = baseRad * (180 / pi);

  /// This is the point where the curvature of the tip ends and the straight line begins.
  /// This point is always within a quarter of a circle (under 90º) and is inversely proportional to the baseAngle.
  ///
  /// For example, if the baseAngle is 30º, the contactAngle will be 60º.
  double contactAngle = 90 - baseAngle;

  /// The contact angle in radians, used to calculate the middle triangle inside the circle at the tip.
  double contactRad = contactAngle * (pi / 180);

  /// In this case, we are constructing a right triangle inside the circle used to draw the curvature,
  /// using the contact angle as a reference.
  ///
  /// [catetoAdjacenteMedio] = middle adjacent side.
  double catetoAdjacenteMedio = cos(contactRad) * radius;

  /// [catetoOpostoMedio] = middle opposite side.
  double catetoOpostoMedio = sin(contactRad) * radius;

  /// The adjacent side of the smaller right triangle represents the distance between the middle right
  /// triangle and the border of the isosceles triangle.
  ///
  /// [catetoAdjacenteMenor] = small adjacent side
  double catetoAdjacenteMenor = catetoOpostoMedio / tan(baseRad);

  /// The sum of the middle adjacent side and smaller adjacent side represents the adjacent side of the larger
  /// triangle, while the opposite side represents the borderDistance between the triangle's tip and the
  /// center of the circle used to draw the tip's curvature.
  ///
  /// [catetoAdjacenteMaior] = large adjacent side;
  double catetoAdjacenteMaior = catetoAdjacenteMenor + catetoAdjacenteMedio;

  /// The opposite side of the larger triangle, also represents the distance between the triangle's tip and the
  /// center of the circle used to draw the tip's curvature;
  ///
  /// [borderDistance] = large opposite side;
  double borderDistance = catetoAdjacenteMaior * tan(baseRad);
  if (borderDistance < radius) borderDistance = radius;

  /// [initialAngle] starts with the angle where the tip's curvature begins in radians;
  ///
  /// For each direction the triangle is facing, [initialAngle] receives the amount of degrees in radians
  /// to make sure the tip will be facing the right direction;
  double initialAngle = contactAngle * (pi / 180);
  Offset offset;
  switch (triangleDirection) {
    case TriangleDirection.top:
      offset = Offset(size.width / 2, borderDistance);
      initialAngle += pi;
      break;
    case TriangleDirection.right:
      offset = Offset(size.width - borderDistance, size.height / 2);
      initialAngle += 3 * pi / 2;
      break;
    case TriangleDirection.bottom:
      offset = Offset(size.width / 2, size.height - borderDistance);
      initialAngle += 0;
      break;
    default:
      offset = Offset(borderDistance, size.height / 2);
      initialAngle += pi / 2;
      break;
  }

  final rect = Rect.fromCircle(center: offset, radius: radius);

  /// The amount of the circle being drawn taking [initialAngle] as starting point;
  double sweepAngle = ((180 - contactAngle * 2) * pi) / 180;

  return path..arcTo(rect, initialAngle, sweepAngle, false);
}

/// Constructs the starting point of a triangle with a rounded corner;
///
/// The starting point of a triangle pointing upwards is the left base corner;
Path _triangleStart(
  Size size,
  double radius,
  Path path,
  TriangleDirection triangleDirection,
) {
  double base =
      triangleDirection.orientation == "vertical" ? size.width : size.height;
  double height =
      triangleDirection.orientation == "vertical" ? size.height : size.width;

  /// Hypotenuse.
  double hipotenusa = radius;
  double baseRad = atan(height / (base / 2));
  double baseAngle = baseRad * (180 / pi);
  double contactAngle = 90 - baseAngle;
  double contactRad = contactAngle * (pi / 180);

  /// Opposite side of the smaller right triangle built using [radius] as [hipotenusa]
  /// and [contactAngle];
  ///
  /// [catetoOpostoMenor] = Opposite side of the small right triangle;
  double catetoOpostoMenor = sin(contactRad) * hipotenusa;

  /// [catetoAdjacenteMenor] = Adjacent side of the small right triangle;
  double catetoAdjacenteMenor = cos(contactRad) * hipotenusa;

  /// The opposite side of the big right triangle used to calculate the distance between
  /// the center of the circle used for building the rounded corner and the borders
  /// of the available space;
  ///
  /// [catetoOpostoMaior] = opposite side of the big right triangle;
  double catetoOpostoMaior = catetoOpostoMenor + radius;

  /// [catetoAdjacenteMaior] = Adjacent side of the big right triangle;
  double catetoAdjacenteMaior = catetoOpostoMaior / tan(baseRad);

  /// The sum of adjacent side of big right triangle and adjacent side of small right triangle.
  /// Defines the distante betwenn the center of the circle used for building the rounded corner
  /// and the border of the dimensions given;
  ///
  /// On a triangle pointing upwards, this representes the distance between the center of the
  /// rounded corner and the left side of the width given;
  double borderDistance = catetoAdjacenteMaior + catetoAdjacenteMenor;

  /// The distance between the border of the corner and the center point of the rounded corner
  /// is equal to [radius], if this value gets bigger than the [borderDistance] then the corner
  /// gets cut out for exceding the dimensions given;
  if (borderDistance < radius) borderDistance = radius;

  Offset offset;
  double initialAngle;
  switch (triangleDirection) {
    case TriangleDirection.top:
      offset = Offset(borderDistance, size.height - radius);
      initialAngle = pi / 2;
      break;
    case TriangleDirection.right:
      offset = Offset(radius, borderDistance);
      initialAngle = pi;
      break;
    case TriangleDirection.bottom:
      offset = Offset(size.width - borderDistance, radius);
      initialAngle = pi * 1.5;
      break;
    default:
      offset = Offset(size.width - radius, size.height - borderDistance);
      initialAngle = 0;
      break;
  }

  final rect = Rect.fromCircle(center: offset, radius: radius);

  double sweepAngle = ((90 + contactAngle) * pi) / 180;

  return path..arcTo(rect, initialAngle, sweepAngle, false);
}

/// Constructs the final rounded corner of the triangle, using the same logic of [_triangleStart];
_triangleEnd(
  Size size,
  double radius,
  Path path,
  TriangleDirection triangleDirection,
) {
  double base =
      triangleDirection.orientation == "vertical" ? size.width : size.height;
  double height =
      triangleDirection.orientation == "vertical" ? size.height : size.width;
  double hipotenusa = radius;
  double baseRad = atan(height / (base / 2));
  double baseAngle = baseRad * (180 / pi);
  double contactAngle = 90 - baseAngle;
  double contactRad = contactAngle * (pi / 180);

  double catetoOpostoMenor = sin(contactRad) * hipotenusa;
  double catetoAdjacenteMenor = cos(contactRad) * hipotenusa;

  double catetoOpostoMaior = catetoOpostoMenor + radius;

  double catetoAdjacenteMaior = catetoOpostoMaior / tan(baseRad);
  double borderDistance = catetoAdjacenteMaior + catetoAdjacenteMenor;
  if (borderDistance < radius) borderDistance = radius;

  Offset offset;
  double initialAngle = baseRad;
  switch (triangleDirection) {
    case TriangleDirection.top:
      offset = Offset(size.width - borderDistance, size.height - radius);
      initialAngle += pi * 1.5;
      break;
    case TriangleDirection.right:
      offset = Offset(radius, size.height - borderDistance);
      initialAngle += 0;
      break;
    case TriangleDirection.bottom:
      offset = Offset(borderDistance, radius);
      initialAngle += pi / 2;
      break;
    default:
      offset = Offset(size.width - radius, borderDistance);
      initialAngle += pi;
      break;
  }

  final rect = Rect.fromCircle(center: offset, radius: radius);

  double sweepAngle = ((90 + contactAngle) * pi) / 180;
  return path..arcTo(rect, initialAngle, sweepAngle, false);
}
