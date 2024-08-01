import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final IconData? sufixIcon;
  final TextEditingController? controller;
  final String? initaialValue;
  final String? Function(String?)? validate;
  final String? Function(String?)? onsave;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.sufixIcon,
    this.initaialValue,
    this.validate,
    this.controller,
    this.onsave,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onsave,
      controller: controller,
      validator: validate,
      initialValue: initaialValue,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xffFAFAFA),
        hintText: hintText,
        suffixIcon: Icon(sufixIcon),
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xffFAFAFA),
          ),
          borderRadius:
              BorderRadius.circular(12), // Changed color to 0xffFFFFFF
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.blue,
        ),
      ),
    );
  }
}
