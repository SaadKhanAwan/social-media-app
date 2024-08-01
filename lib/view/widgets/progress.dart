import 'package:flutter/material.dart';

Container circulaprogress(Color col) {
  return Container(
    padding: const EdgeInsets.only(top: 10),
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(col),
    ),
  );
}

Container linearprogress() {
  return Container(
    padding: const EdgeInsets.only(bottom: 10),
    alignment: Alignment.center,
    child: const LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
  );
}
