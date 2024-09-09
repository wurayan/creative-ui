import 'dart:math';

import 'package:creative_app/widget/custom_shape_shadow.dart';
import 'package:flutter/material.dart';

// Defines the direction the triangle is "pointing", which means, the oposite of the base of the Triangle;
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

///Creates a Triangle that takes all the space provided by *child*;
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

class _CustomTriangleClipper extends CustomClipper<Path> {
  final TriangleDirection triangleDirection;
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
    double r = radius;
    double w = size.width;
    double h = size.height;

    ///As of Isosceles Triangle, the base will always be the width of the container, while both other sides will
    /// be equal to triangleSide;
    double triangleSide = sqrt(pow((w / 2), 2) + pow(h, 2));

    ///triangleSemiperimeter is half the sum of all triangle sides;
    double triangleSemiperimeter = (triangleSide * 2 + w) / 2;

    double triangleArea = (w * h) / 2;

    ///The maximum possible radius for the dimensions given;
    double maxRadius = triangleArea / triangleSemiperimeter;

    ///The side of a square that occupies tha maximum space possible inside a circle, it's used to
    /// calculate the points where the triangle sides touch the rounded corners;
    double squareSide = r * sqrt(2);

    ///Used to calculate the distance between the end of the lines of the triangle and the border of the
    /// container;
    double borderDistance;

    ///If the radius informed are bigger or equal than the maxRadius, the triangle turns into a circle;
    ///TODO Corrigir o círculo que está tomando o container inteiro invés de manter as dimensões internas do
    /// triangulo;
    /// Outro problema é que este calculo não é o melho para essa situação, o ideal seria medir o tamanho de
    ///   cada linha, se for 0 nós construimos sem as linhas e depois testamos;
    if (r >= maxRadius) {
      path.moveTo(w / 2, h);
      path.arcToPoint(
        Offset(w / 2, 0),
        radius: Radius.circular(r),
      );
      path.arcToPoint(
        Offset(w / 2, h),
        radius: Radius.circular(r),
      );
      return path;
    }

    switch (triangleDirection) {
      case TriangleDirection.right:
        //θ = arctan(2h/b), este calculo pega o angulo adjacente á base do triangulo isósceles;
        //θ equivale a (α) um dos angulos do triangulo retangulo que delimita a distancia das linhas
        //  para a borda
        double arctan = atan(2 * w / h);

        //O cateto maior do Triangulo retangulo e oposto ao arctan (ponta do triangulo maior);
        double catetoMaior = r + squareSide / 2;

        //O calculo da hipotenusa é sin(α) = CO/h logo h = CO/sin(α);
        double hipotenusa = catetoMaior / sin(arctan);

        //borderDistance equivale ao catetoMenor, no caso do triângulo apontando para direita o borderDistance
        //  equivale a Y;
        borderDistance = sqrt(pow(hipotenusa, 2) - pow(catetoMaior, 2));

        //Altura do triangulo menor medido para a ponta do Triangulo maior, utilizando as mesmas proporções do
        //  triangulo maior porém com squareSide como base, no caso da ponta para a direita alphaH é X;
        double alphaH = (squareSide * h) / w;
        path.moveTo(r + squareSide / 2, borderDistance);
        path.lineTo(w - alphaH, h / 2 - squareSide / 2);
        path.quadraticBezierTo(
            w - alphaH + r, h / 2, w - alphaH, h / 2 + squareSide / 2);
        path.lineTo(r + squareSide / 2, h - borderDistance);
        path.quadraticBezierTo(0, h, 0, h - borderDistance - squareSide / 2);
        path.lineTo(0, borderDistance + squareSide / 2);
        path.quadraticBezierTo(0, 0, r + squareSide / 2, borderDistance);
        break;
      case TriangleDirection.bottom:
        path.lineTo(size.width, 0);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(0, 0);
        break;
      case TriangleDirection.left:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height / 2);
        break;
      default:
        // path = _trianglePoint(size, radius, path);
        path.moveTo(0, h);
        path = _triangleTip(size, radius, path, triangleDirection);
        path.lineTo(w, h);

        break;
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

//TODO tem um ponto onde o angulo da base do triangulo é tão pequeno que a ponta não é
//  construida, temos que descobrir pq;
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

  //O calculo da ponta constrói um trinagulo retangulo dentro do circulo, nesse caso
  //  a hipotenusa será sempre o raio/linha mais longa entre o meio e a extremidade
  //  do circulo
  double hipotenusa = radius;

  //θ = arctan(2h/b), este calculo pega o angulo adjacente á base do triangulo isósceles;
  //  θ é igual ao ponto que a linha tocará o circulo usado como base para criar a
  //  curvatura da ponta;
  double arctan = atan(height / (base / 2));

  //Problema que encnotramos é que arctan retorna o valor em Radianos, logo as contas
  //  seguintes buscavam seno de 1, invés de seno do angulo que representa 1 em radianos;
  double anguloBase = arctan * (180 / pi);

  //O ponto de contato da linha com o círculo da ponta é inversamente proporcional ao
  //  angulo entre a linha do meio do circulo, ou seja quanto menor o anguloBase, maior
  //  o angulo de contato;
  // Usamos 90º pois sabemos que o angulo de contato estará sempre dentro de 1/4 de círculo;
  double anguloContato = 90 - anguloBase;

  //Como arctan representa o angulo interno do triangulo retangulo no qual CatetoOposto
  //  representa a distância entre a ponta da linha da base do triangulo Isóscele;
  double catetoOposto = sin(arctan) * hipotenusa;

  //Cateto adjacente represeta a distancia do meio do circulo até a ponta da reta
  //  conectado ao círculo;
  double catetoAdjacente = cos(arctan) * hipotenusa;

  //Calcula a distância entre a borda e o centro do Circulo usando de referencia para
  //  o desenho da ponta arredondada;
  double alphaH = (radius * 2 * height) / base;

  Offset offset;
  switch (triangleDirection) {
    case TriangleDirection.top:
      offset = Offset(size.width / 2, alphaH);
      break;
    case TriangleDirection.right:
      offset = Offset(size.width - alphaH, size.height / 2);
      break;
    case TriangleDirection.bottom:
      offset = Offset(size.width / 2, size.height - alphaH);
      break;
    default:
      offset = Offset(alphaH, size.height / 2);
  }

  final rect = Rect.fromCircle(center: offset, radius: radius);

  //Calculando o radiano equivalente ao ponto inicial da curva que será desenhada;
  //Somamos 180 pois o angulo inicial de 0º é equivalente a 3 horas e é desenhado
  //  usando sentido horário, logo devemos somar 180º para iniciar o desenho na
  //  parte superior esquerda do círculo;
  double initialAngle = ((anguloContato + 180) * pi) / 180;
  double sweepAngle = ((180 - anguloContato * 2) * pi) / 180;

  return path
    ..arcTo(rect, initialAngle, sweepAngle, false)
    ..lineTo(size.width, size.height);
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

  //Define a distancia do ponto de contato com a base do Triangulo, também usada para
  //  o cálculo da distancia do ponto até a borda;
  double catetoOpostoMaior = catetoOpostoMenor + radius;

  double borderDistance = tan(arctan) * catetoOpostoMaior;

  Offset offset;
  double initialAngle;
  switch (triangleDirection) {
    case TriangleDirection.top:
      offset = Offset(borderDistance + radius, size.height - radius);
      initialAngle = pi / 2;
      break;
    case TriangleDirection.right:
      offset = Offset(radius, borderDistance + radius);
      initialAngle = pi;
      break;
    case TriangleDirection.bottom:
      offset = Offset(size.width - borderDistance - radius, radius);
      initialAngle = pi * 1.5;
      break;
    default:
      offset =
          Offset(size.width - radius, size.width - borderDistance - radius);
      initialAngle = 0;
      break;
  }

  final rect = Rect.fromCircle(center: offset, radius: radius);

  //SweepAngle não entra no switch pq independente da onde começa a Curva, ela
  //  sempre percorrerá a mesma distância;
  double sweepAngle = ((90 + anguloContato) * pi) / 180;

  return path..arcTo(rect, initialAngle, sweepAngle, false);
}

pointingTopTriangle(Path path, Size size, double radius) {
  double r = radius.clamp(
      0.0, size.width > size.height ? size.height / 2 : size.width / 2);
  double w = size.width;
  double h = size.height;
  path.moveTo(r, h - r * 1.4);
  path.arcToPoint(
    Offset(r * 2, h),
    radius: Radius.circular(r),
    clockwise: false,
  );
  path.lineTo(w - r * 2, h);
  path.arcToPoint(
    Offset(w - r, h - r * 1.4),
    radius: Radius.circular(r),
    clockwise: false,
  );
  path.lineTo(w / 2 + r, r * 2);
  path.arcToPoint(
    Offset(w / 2 - r, r * 2),
    radius: Radius.circular(r * 1.1),
    clockwise: false,
  );
  path.close();
  return path;
}
