import 'dart:math';
import 'package:creative_app/widget/custom_shape_shadow.dart';
import 'package:flutter/material.dart';

///Defines the direction the triangle is "pointing", which means, the oposite of
///the base of the Triangle;
enum TriangleDirection {
  top,
  right,
  bottom,
  left,
  ;

  String get orientation =>
      this == TriangleDirection.top || this == TriangleDirection.bottom
          ? "vertical"
          : "horizontal";
}

///Creates a Triangle that takes all the space provided by [child];
///If child is a Container, the Triangle Base takes all the extent of the Container Side;
///If child is of another Widget the Triangle will clip its child;
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

  Path _roundedTriangleBuilder(Path path, Size size, double radius) {
    double width = size.width;
    double height = size.height;

    ///Since whe're building an Isosceles Triangle the sides (not counting the base) will
    /// always be equal;
    double triangleSide = sqrt(pow((width / 2), 2) + pow(height, 2));

    ///triangleSemiperimeter is half the sum of all triangle sides;
    double triangleSemiperimeter = (triangleSide * 2 + width) / 2;
    double triangleArea = (width * height) / 2;

    ///The maximum radius possible for the biggest circle inside the triangle;
    //TODO we may not need this value if whe're limiting radius to be half the
    //  the size of the smallest side;
    double maxRadius1 = triangleArea / triangleSemiperimeter;

    ///The maximum possible radius taking the height and width into account;
    double maxRadius2 = min(size.width / 2, size.height / 2);

    if (radius > min(maxRadius1, maxRadius2)) {
      radius = min(maxRadius1, maxRadius2);
    }

    switch (triangleDirection) {
      case TriangleDirection.right:
        path = _triangleStart(size, radius, path, triangleDirection);
        path = _triangleTip(size, radius, path, triangleDirection);
        path = _triangleEnd(size, radius, path, triangleDirection);
        break;
      case TriangleDirection.bottom:
        path = _triangleStart(size, radius, path, triangleDirection);
        path = _triangleTip(size, radius, path, triangleDirection);
        path = _triangleEnd(size, radius, path, triangleDirection);
        break;
      case TriangleDirection.left:
        path = _triangleStart(size, radius, path, triangleDirection);
        path = _triangleTip(size, radius, path, triangleDirection);
        path = _triangleEnd(size, radius, path, triangleDirection);
        break;
      default:
        path = _triangleStart(size, radius, path, triangleDirection);
        path = _triangleTip(size, radius, path, triangleDirection);
        path = _triangleEnd(size, radius, path, triangleDirection);
        break;
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

///Builds the tip of the Triangle;
Path _triangleTip(
  Size size,
  double radius,
  Path path,
  TriangleDirection triangleDirection,
) {
  ///We check the orientation of the triangle to define if it is pointing horizontally or vertically;
  double base =
      triangleDirection.orientation == "vertical" ? size.width : size.height;
  double height =
      triangleDirection.orientation == "vertical" ? size.height : size.width;

  ///We use the formula `θ = arctan(2h/b)` to calculate the angle adjacent to the base of the Triangle
  /// in Rad, this angle equals the the angle in which the curvature of the tip starts and ends
  double baseRad = atan(height / (base / 2));

  ///We convert the baseRad to angle;
  double baseAngle = baseRad * (180 / pi);

  ///Half the angle of the tip of the triangle, this represents one of the angles inside the biggest
  ///square traingle used to calculate de borderDistance;
  double topRad = atan(base / 2 / height);

  ///Converting the [topRad] to angles;
  double topAngle = topRad * 180 / pi;

  ///Is the point where the curvature of the tip ends and the straight line starts, this point
  /// will always be inside a quarter of a Circle (under 90º) and is inversely proportional to
  /// the baseAngle, which means if the baseAngle is 30º, then contact angle is 60º;
  double contactAngle = 90 - baseAngle;

//Radiano do angulo de contato, usamos para o canculo do triangulo medio dentro do criculo da ponta;
  double contactRad = contactAngle * (pi / 180);

//Nesse caso estamos construindo um triangulo retangulo dentro do circulo usado para o desenho da curva,
//tendo o angulo de contato como
  double catetoAdjacenteMedio = cos(contactRad) * radius;

  //é o mesmo que cateto oposto menor;
  double catetoOpostoMedio = sin(contactRad) * radius;

  //cateto adjacente do menor triangulo retangulo, representa a distancia entre triangulo retangulo medio e
  //borda do triangulo isosceles;
  double catetoAdjacenteMenor = catetoOpostoMedio / tan(baseRad);

  // a soma dos catetos representa o cateto Adjacente do maior triangulo, o qual o cateto oposto representa
  // a borderDistance entre a ponta to triangulo e o centro da esfera usada para desenhar a curvatora do ponta;
  double catetoAdjacenteMaior = catetoAdjacenteMenor + catetoAdjacenteMedio;

  //Cateto oposto maior calculado a partir do valor acima;
  //Estamos substituindo todos os AlphaH com borderDistance;
  double borderDistance = catetoAdjacenteMaior * tan(baseRad);
  if (borderDistance < radius) borderDistance = radius;

  ///We use cross-multiplication to determine the distance between the center of the reference
  /// circle for the tip and the border, alphaH equals the height of a smaller triangle with the same
  /// proportions of the Triangle being drawn using 2radius as base;
  /// TODO we won't use the alphaH anymore, because it will reduce the triangle height if
  /// the base used in calculation is too small and we want to make the triangle as big as possible;
  double alphaH = (radius * 2 * height) / base;

  ///A check if alphaH is smaller than radius, because alphaH determines the distance from
  /// the center of the circle to the border of the container, so if alphaH is too small, the
  /// curvature is drawn outside of the dimensions given, being cut by the border;
  ///
  ///Since we limit radius to never be bigger than half the height of the triangle, we can
  /// assure the alphaH will be always at equal distance from the borders of the container;
  if (alphaH < radius) alphaH = radius;

  //Definimos o angulo inicial através do rad de anguloContato pois vamos somar o valor inicial
  //  do circulo ao anguloContato para saber o ponto exato que a curvatura se inicia;
  ///The angle
  double initialAngle = contactAngle * (pi / 180);
  Offset offset;
  switch (triangleDirection) {
    case TriangleDirection.top:
      // offset = Offset(size.width / 2, alphaH);
      offset = Offset(size.width / 2, borderDistance);
      //converte o angulo do contato para radiano;
      initialAngle += pi;
      break;
    case TriangleDirection.right:
      // offset = Offset(size.width - alphaH, size.height / 2);
      offset = Offset(size.width - borderDistance, size.height / 2);
      initialAngle += 3 * pi / 2;
      break;
    case TriangleDirection.bottom:
      // offset = Offset(size.width / 2, size.height - alphaH);
      offset = Offset(size.width / 2, size.height - borderDistance);
      initialAngle += 0;
      break;
    default:
      // offset = Offset(alphaH, size.height / 2);
      offset = Offset(borderDistance, size.height / 2);
      initialAngle += pi / 2;
      break;
  }

  final rect = Rect.fromCircle(center: offset, radius: radius);

  // //Calculando o radiano equivalente ao ponto inicial da curva que será desenhada;
  // //Somamos 180 pois o angulo inicial de 0º é equivalente a 3 horas e é desenhado
  // //  usando sentido horário, logo devemos somar 180º para iniciar o desenho na
  // //  parte superior esquerda do círculo;
  // double initialAngle = ((anguloContato + 180) * pi) / 180;
  double sweepAngle = ((180 - contactAngle * 2) * pi) / 180;

  return path..arcTo(rect, initialAngle, sweepAngle, false);
}

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
  double hipotenusa = radius;
  double arctan = atan(height / (base / 2));
  double anguloBase = arctan * (180 / pi);
  double anguloContato = 90 - anguloBase;

  //Cateto oposto do Triangulo Retangulo construido dentro do circulo usado para ponta
  //  inicial do Triangulo, este valor somado com o Raio define a distancia do final
  //  do circulo para a base do Triangulo;
  double catetoOpostoMenor = sin(arctan) * hipotenusa;
  double catetoAdjacenteMenor = cos(arctan) * hipotenusa;

  //Define a distancia do ponto de contato com a base do Triangulo, também usada para
  //  o cálculo da distancia do ponto até a borda;
  double catetoOpostoMaior = catetoOpostoMenor + radius;

  double catetoAdjacenteMaior = catetoOpostoMaior / tan(arctan);

  double borderDistance = catetoAdjacenteMaior + catetoAdjacenteMenor;
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

  //SweepAngle não entra no switch pq independente da onde começa a Curva, ela
  //  sempre percorrerá a mesma distância;
  double sweepAngle = ((90 + anguloContato) * pi) / 180;
  // double endSweepAngle =

  return path..arcTo(rect, initialAngle, sweepAngle, false);
}

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
  double arctan = atan(height / (base / 2));
  double anguloBase = arctan * (180 / pi);
  double anguloContato = 90 - anguloBase;

  double catetoOpostoMenor = sin(arctan) * hipotenusa;
  double catetoAdjacenteMenor = cos(arctan) * hipotenusa;

  //Define a distancia do ponto de contato com a base do Triangulo, também usada para
  //  o cálculo da distancia do ponto até a borda;
  double catetoOpostoMaior = catetoOpostoMenor + radius;

  double catetoAdjacenteMaior = catetoOpostoMaior / tan(arctan);
  double borderDistance = catetoAdjacenteMaior + catetoAdjacenteMenor;
  if (borderDistance < radius) borderDistance = radius;

  Offset offset;
  double initialAngle = arctan;

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

  double sweepAngle = ((90 + anguloContato) * pi) / 180;
  return path..arcTo(rect, initialAngle, sweepAngle, false);
}
