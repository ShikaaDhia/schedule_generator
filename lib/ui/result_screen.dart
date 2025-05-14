import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ResultScreen extends StatelessWidget {
  final String result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generated Schedule"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: MarkdownBody(
            data: result,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: const TextStyle(fontSize: 16),
              h1: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
              h2: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
          ),
        ),
      ),
    )
  );
  }
}