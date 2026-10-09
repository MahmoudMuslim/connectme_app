import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 375,
          height: 812,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.50, 1.00),
              end: Alignment(0.50, 0.00),
              colors: [const Color(0xFF5151C6), const Color(0xFF888BF4)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 375,
                top: 812,
                child: Container(
                  width: 375,
                  height: 812,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
              Positioned(
                left: 386,
                top: 0,
                child: Container(
                  transform: Matrix4.identity()
                    ..translate(0.0, 0.0)
                    ..rotateZ(1.57),
                  width: 966,
                  height: 445,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/966x445"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 375,
                  height: 812,
                  decoration: BoxDecoration(color: const Color(0x665252C7)),
                ),
              ),
              Positioned(
                left: 14.89,
                top: 195,
                child: Container(
                  width: 345.40,
                  height: 422.42,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 147.36,
                        top: 281,
                        child: Opacity(
                          opacity: 0.70,
                          child: Container(
                            transform: Matrix4.identity()
                              ..translate(0.0, 0.0)
                              ..rotateZ(0.79),
                            width: 136,
                            height: 64,
                            decoration: ShapeDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(0.50, -0.00),
                                end: Alignment(0.50, 1.00),
                                colors: [
                                  const Color(0x005151C6),
                                  const Color(0xFF5151C6),
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 147.36,
                        top: 0,
                        child: Container(
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(0.79),
                          width: 136,
                          height: 64,
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(1.03, -0.02),
                              end: Alignment(0.00, 1.00),
                              colors: [
                                const Color(0xFF5151C6),
                                const Color(0x005151C6),
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 79.03,
                        top: 108.67,
                        child: Container(
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(-0.79),
                          width: 132.47,
                          height: 132.47,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFC4C4C4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 78.65,
                        top: -11.49,
                        child: Container(
                          width: 187.94,
                          height: 282.32,
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://placehold.co/188x282",
                              ),
                              fit: BoxFit.cover,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 79.03,
                        top: 313.57,
                        child: Container(
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(-0.79),
                          width: 132.47,
                          height: 132.47,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFC4C4C4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 32.29,
                        top: 219.50,
                        child: Container(
                          width: 281.49,
                          height: 187.94,
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://placehold.co/281x188",
                              ),
                              fit: BoxFit.cover,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 202.57,
                        child: Container(
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(-0.79),
                          width: 103.82,
                          height: 128,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFC4C4C4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0.11,
                        top: 129,
                        child: Container(
                          width: 164,
                          height: 202,
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://placehold.co/164x202",
                              ),
                              fit: BoxFit.cover,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 181.48,
                        top: 202.57,
                        child: Container(
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(-0.79),
                          width: 103.82,
                          height: 128,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFC4C4C4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 181.32,
                        top: 90.34,
                        child: Container(
                          width: 162.27,
                          height: 242.58,
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://placehold.co/162x243",
                              ),
                              fit: BoxFit.cover,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
