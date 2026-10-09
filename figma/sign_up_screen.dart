import 'package:flutter/material.dart';

class SignUp extends StatelessWidget {
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
                top: 0,
                child: Container(
                  width: 375,
                  height: 44,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 19.89,
                        top: 14,
                        child: SizedBox(
                          width: 54,
                          child: Text(
                            '9:41',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'SF Pro Text',
                              fontWeight: FontWeight.w600,
                              height: 1.20,
                              letterSpacing: -0.17,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 338,
                        top: 19.08,
                        child: Container(
                          width: 18,
                          height: 7.67,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1.60),
                            ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                  'SIGN IN',
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
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Already have account? ',
                            style: TextStyle(
                              color: const Color(0xFF212121),
                              fontSize: 16,
                              fontFamily: 'Circular Std',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                              letterSpacing: -0.20,
                            ),
                          ),
                          TextSpan(
                            text: 'SIGN IN',
                            style: TextStyle(
                              color: const Color(0xFF5555C9),
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}
