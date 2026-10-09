import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
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
                  height: 190,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 375,
                          height: 150,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 375,
                                top: 189.93,
                                child: Container(
                                  transform: Matrix4.identity()
                                    ..translate(0.0, 0.0)
                                    ..rotateZ(-3.14),
                                  width: 432,
                                  height: 230.94,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        "https://placehold.co/432x231",
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Opacity(
                                  opacity: 0.50,
                                  child: Container(
                                    width: 375,
                                    height: 150,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF212121),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(2),
                                      ),
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
                        top: 44,
                        child: Container(
                          width: 375,
                          height: 56,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 24,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(),
                                child: Stack(),
                              ),
                              SizedBox(
                                width: 247,
                                child: Text(
                                  '@brunopham',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Circular Std',
                                    fontWeight: FontWeight.w700,
                                    height: 1.20,
                                  ),
                                ),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 9.54,
                                      top: 9.25,
                                      child: Container(
                                        width: 5.27,
                                        height: 5.27,
                                        decoration: ShapeDecoration(
                                          shape: OvalBorder(
                                            side: BorderSide(
                                              width: 1.50,
                                              strokeAlign:
                                                  BorderSide.strokeAlignCenter,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 147,
                        top: 110,
                        child: Container(
                          width: 80,
                          height: 80,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: ShapeDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        "https://placehold.co/80x80",
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    shape: OvalBorder(
                                      side: BorderSide(
                                        width: 4,
                                        strokeAlign:
                                            BorderSide.strokeAlignCenter,
                                        color: Colors.white,
                                      ),
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
              ),
              Positioned(
                left: 14,
                top: 206,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 20,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 6,
                      children: [
                        Text(
                          'Bruno Pham',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF242424),
                            fontSize: 20,
                            fontFamily: 'Circular Std',
                            fontWeight: FontWeight.w700,
                            height: 1.20,
                          ),
                        ),
                        Text(
                          'Da Nang, Vietnam',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF8F8FA6),
                            fontSize: 16,
                            fontFamily: 'Circular Std',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                            letterSpacing: -0.20,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 347,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF5F6F8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 48,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '220',
                                  style: TextStyle(
                                    color: const Color(0xFF242424),
                                    fontSize: 16,
                                    fontFamily: 'Circular Std',
                                    fontWeight: FontWeight.w700,
                                    height: 1.50,
                                    letterSpacing: 0.60,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ',
                                  style: TextStyle(
                                    color: const Color(0xFF242424),
                                    fontSize: 16,
                                    fontFamily: 'Circular Std',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                    letterSpacing: -0.20,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Followers',
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
                            textAlign: TextAlign.center,
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '150',
                                  style: TextStyle(
                                    color: const Color(0xFF242424),
                                    fontSize: 16,
                                    fontFamily: 'Circular Std',
                                    fontWeight: FontWeight.w700,
                                    height: 1.50,
                                    letterSpacing: 0.60,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ',
                                  style: TextStyle(
                                    color: const Color(0xFF242424),
                                    fontSize: 16,
                                    fontFamily: 'Circular Std',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                    letterSpacing: -0.20,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Following',
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
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 24,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(),
                        ),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(1.00, 1.00),
                              end: Alignment(-0.00, 0.00),
                              colors: [
                                const Color(0xFF888BF4),
                                const Color(0xFF5151C6),
                              ],
                            ),
                            shape: OvalBorder(),
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(),
                        ),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(1.00, 1.00),
                              end: Alignment(-0.00, 0.00),
                              colors: [
                                const Color(0xFF888BF4),
                                const Color(0xFF5151C6),
                              ],
                            ),
                            shape: OvalBorder(),
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                top: 383,
                child: Container(
                  width: 375,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 10,
                          ),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 10,
                            children: [
                              SizedBox(
                                width: 110,
                                child: Text(
                                  '200 shots',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFFBDBDBD),
                                    fontSize: 16,
                                    fontFamily: 'Circular Std',
                                    fontWeight: FontWeight.w400,
                                    height: 1.20,
                                    letterSpacing: -0.10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 10,
                          ),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF1F1FD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 10,
                            children: [
                              SizedBox(
                                width: 110,
                                child: Text(
                                  '10 Collections',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF888BF4),
                                    fontSize: 16,
                                    fontFamily: 'Circular Std',
                                    fontWeight: FontWeight.w700,
                                    height: 1.20,
                                    letterSpacing: -0.10,
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
                left: 20,
                top: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Container(
                      width: 158,
                      height: 158,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 79,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 79,
                            top: 79,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 79,
                            top: 0,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 158,
                              height: 158,
                              decoration: BoxDecoration(
                                color: const Color(0x7F333333),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 39,
                            top: 68,
                            child: Text(
                              'YOUR LIKES',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Circular Std',
                                fontWeight: FontWeight.w700,
                                height: 1.20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '25 shots',
                      style: TextStyle(
                        color: const Color(0xFF828282),
                        fontSize: 14,
                        fontFamily: 'Circular Std',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: -0.10,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                top: 651,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Container(
                      width: 158,
                      height: 158,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 79,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 79,
                            top: 79,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 79,
                            top: 0,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 158,
                              height: 158,
                              decoration: BoxDecoration(
                                color: const Color(0x7F333333),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 25,
                            top: 59,
                            child: Text(
                              'PORTRAIT\nPHOTOGRAPHY',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Circular Std',
                                fontWeight: FontWeight.w700,
                                height: 1.20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '25 shots',
                      style: TextStyle(
                        color: const Color(0xFF828282),
                        fontSize: 14,
                        fontFamily: 'Circular Std',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: -0.10,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 197,
                top: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Container(
                      width: 158,
                      height: 158,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 79,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 79,
                            top: 79,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 79,
                            top: 0,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 158,
                              height: 158,
                              decoration: BoxDecoration(
                                color: const Color(0x7F333333),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 37,
                            top: 68,
                            child: Text(
                              'DOWNLOAD',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Circular Std',
                                fontWeight: FontWeight.w700,
                                height: 1.20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '25 shots',
                      style: TextStyle(
                        color: const Color(0xFF828282),
                        fontSize: 14,
                        fontFamily: 'Circular Std',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: -0.10,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 197,
                top: 651,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Container(
                      width: 158,
                      height: 158,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 79,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 79,
                            top: 79,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 79,
                            top: 0,
                            child: Container(
                              width: 79,
                              height: 79,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://placehold.co/79x79",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 158,
                              height: 158,
                              decoration: BoxDecoration(
                                color: const Color(0x7F333333),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 25,
                            top: 59,
                            child: Text(
                              'PORTRAIT\nPHOTOGRAPHY',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Circular Std',
                                fontWeight: FontWeight.w700,
                                height: 1.20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '25 shots',
                      style: TextStyle(
                        color: const Color(0xFF828282),
                        fontSize: 14,
                        fontFamily: 'Circular Std',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: -0.10,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                top: 707,
                child: Container(
                  width: 375,
                  height: 105,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 88,
                        top: 46,
                        child: Container(width: 24, height: 24, child: Stack()),
                      ),
                      Positioned(
                        left: 327,
                        top: 46,
                        child: Container(width: 24, height: 24, child: Stack()),
                      ),
                      Positioned(
                        left: 24,
                        top: 46,
                        child: Container(width: 24, height: 24, child: Stack()),
                      ),
                      Positioned(
                        left: 157,
                        top: 0,
                        child: Container(
                          width: 60,
                          height: 60,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 60,
                                  height: 60,
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
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 18,
                                top: 18,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  child: Stack(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 263,
                        top: 46,
                        child: Container(width: 24, height: 24, child: Stack()),
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
