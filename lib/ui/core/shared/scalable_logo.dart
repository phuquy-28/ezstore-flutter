import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScalableStoreLogo extends StatelessWidget {
  final double width;
  final double height;

  const ScalableStoreLogo({
    super.key,
    this.width = 100,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: SvgPicture.asset(
        'assets/svgs/logo.svg',
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}
