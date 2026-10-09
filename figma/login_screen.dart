import 'package:flutter/material.dart';

class SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 375,
          height: 812,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 375,
                  height: 312,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 187,
                          height: 150,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC4C4C4),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -34,
                        top: 0,
                        child: Container(
                          width: 255,
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://placehold.co/255x150",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 187,
                        top: 150,
                        child: Container(
                          width: 188,
                          height: 150,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5F5F5F),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 150,
                        top: 150,
                        child: Container(
                          width: 262,
                          height: 154,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://placehold.co/262x154",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 187,
                        top: 0,
                        child: Container(
                          width: 188,
                          height: 150,
                          decoration: BoxDecoration(
                            color: const Color(0xFF909090),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 153,
                        top: 0,
                        child: Container(
                          width: 255,
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://placehold.co/255x150",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 150,
                        child: Container(
                          width: 187,
                          height: 150,
                          decoration: BoxDecoration(
                            color: const Color(0xFF212121),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -90,
                        top: 150,
                        child: Container(
                          width: 277,
                          height: 163,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://placehold.co/277x163",
                              ),
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
                          height: 312,
                          decoration: BoxDecoration(
                            color: const Color(0xFF212121),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 375,
                        top: 310,
                        child: Opacity(
                          opacity: 0.50,
                          child: Container(
                            transform: Matrix4.identity()
                              ..translate(0.0, 0.0)
                              ..rotateZ(-3.14),
                            width: 767,
                            height: 438,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  "https://placehold.co/767x438",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Opacity(
                          opacity: 0.10,
                          child: Container(
                            width: 375,
                            height: 312,
                            decoration: BoxDecoration(
                              color: const Color(0xFF212121),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 75,
                        top: 126,
                        child: Text(
                          'WELCOME',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'Proxima Nova',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 272,
                child: Container(
                  width: 375,
                  height: 540,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 30,
                top: 312,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 40,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 40,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 20,
                          children: [
                            Container(
                              width: 315,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 13,
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF2F4F6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 24,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Email',
                                          style: TextStyle(
                                            color: const Color(0xFFBDBDBD),
                                            fontSize: 16,
                                            fontFamily: 'Circular Std',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                            letterSpacing: -0.20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 315,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 13,
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF2F4F6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 24,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Password',
                                          style: TextStyle(
                                            color: const Color(0xFFBDBDBD),
                                            fontSize: 16,
                                            fontFamily: 'Circular Std',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                            letterSpacing: -0.20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    child: Stack(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'FORGOT PASSWORD',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF5252C7),
                            fontSize: 14,
                            fontFamily: 'Circular Std',
                            fontWeight: FontWeight.w400,
                            height: 1.20,
                            letterSpacing: 2,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(1.00, 1.00),
                              end: Alignment(-0.00, 0.00),
                              colors: [
                                const Color(0xFF888BF4),
                                const Color(0xFF5151C6),
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 267,
                                child: Text(
                                  'LOG IN',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Circular Std',
                                    fontWeight: FontWeight.w700,
                                    height: 1.50,
                                    letterSpacing: 0.60,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 40,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 14,
                          children: [
                            Text(
                              'OR LOG IN BY',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF5F5F5F),
                                fontSize: 14,
                                fontFamily: 'Circular Std',
                                fontWeight: FontWeight.w400,
                                height: 1.20,
                                letterSpacing: 2,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 20,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFE3E3FC),
                                            shape: OvalBorder(),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 8,
                                        top: 8,
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          child: Stack(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFE3E3FC),
                                            shape: OvalBorder(),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 8,
                                        top: 9,
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          child: Stack(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Don\'t have account? ',
                                style: TextStyle(
                                  color: const Color(0xFF5F5F5F),
                                  fontSize: 16,
                                  fontFamily: 'Circular Std',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                  letterSpacing: -0.20,
                                ),
                              ),
                              TextSpan(
                                text: 'SIGN UP',
                                style: TextStyle(
                                  color: const Color(0xFF5252C7),
                                  fontSize: 16,
                                  fontFamily: 'Circular Std',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                  letterSpacing: -0.20,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
