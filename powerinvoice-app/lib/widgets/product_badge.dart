import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Product Number Badge Widget - Green circle with product number
class ProductBadge extends StatelessWidget {
  final String number;
  final double size;

  const ProductBadge({
    Key? key,
    required this.number,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.successGreen,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
