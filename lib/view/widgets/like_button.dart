import 'package:flutter/material.dart';

class LikeDislike extends StatelessWidget {
  final bool islike;
  final VoidCallback? onTab;
  const LikeDislike({super.key, required this.islike, this.onTab});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTab,
        child: Icon(
          islike ? Icons.favorite : Icons.favorite_border,
          color: islike ? Colors.red : Colors.grey,
        ));
  }
}
