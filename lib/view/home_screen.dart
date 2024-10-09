import 'package:creative_app/widget/custom_triangle.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _currentSliderWidth = 400;
  double _currentSliderHeight = 400;
  double _currentSliderRadius = 40;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Width: $_currentSliderWidth",
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Height: $_currentSliderHeight",
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Radius: $_currentSliderRadius",
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
        Stack(
          children: [
            CustomTriangle(
              triangleDirection: TriangleDirection.top,
              child: Container(
                color: Colors.pink,
                height: _currentSliderHeight,
                width: _currentSliderWidth,
              ),
            ),
            CustomTriangle(
              triangleDirection: TriangleDirection.top,
              borderRadius: _currentSliderRadius,
              child: Container(
                color: Colors.amber,
                width: _currentSliderWidth,
                height: _currentSliderHeight,
              ),
            ),
          ],
        ),
        Slider(
            value: _currentSliderWidth,
            max: 400,
            min: 50,
            divisions: 350,
            onChanged: (value) => setState(() => _currentSliderWidth = value)),
        Slider(
            value: _currentSliderHeight,
            max: 400,
            min: 50,
            divisions: 350,
            onChanged: (value) => setState(() => _currentSliderHeight = value)),
        Slider(
            value: _currentSliderRadius,
            max: 200,
            min: 10,
            divisions: 190,
            onChanged: (value) => setState(() => _currentSliderRadius = value)),
      ],
    ));
  }
}
