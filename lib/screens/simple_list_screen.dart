import 'package:flutter/material.dart';

class SimpleListScreen extends StatelessWidget {
  const SimpleListScreen({
    required this.title,
    required this.emptyMessage,
    super.key,
  });

  final String title;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(emptyMessage)),
    );
  }
}
