import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Client Avatar Widget - Blue circle with client initials
class ClientAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const ClientAvatar({
    Key? key,
    required this.name,
    this.radius = 24,
  }) : super(key: key);

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryBlue,
      child: Text(
        _getInitials(name),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
