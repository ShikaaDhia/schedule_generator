import 'package:flutter/material.dart';

class GenerateButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const GenerateButton({super.key, required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return isLoading
    ? const CircularProgressIndicator()
    : ElevatedButton(
      onPressed: onPressed,
      child: const Text("Genarate Schedule"),
    );
  }
}