import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:password_manager/models/password_entry.dart';
import 'package:password_manager/services/firestore_service.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PasswordHealthScreen extends StatelessWidget {
  final FirestoreService _firestore = FirestoreService();

  PasswordHealthScreen({super.key});

  String evaluatePasswordStrength(String password) {
    if (password.length < 6) return 'Weak';
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    if (score >= 3) return 'Strong';
    if (score >= 2) return 'Medium';
    return 'Weak';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Health'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: StreamBuilder<List<PasswordEntry>>(
        stream: _firestore.getPasswords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No passwords to analyze',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          final passwords = snapshot.data!;
          int weak = 0, medium = 0, strong = 0;
          final passwordHashes = <String, int>{};
          int reused = 0;

          for (var entry in passwords) {
            final strength = evaluatePasswordStrength(entry.password);
            if (strength == 'Weak')
              weak++;
            else if (strength == 'Medium')
              medium++;
            else
              strong++;
            final hash = sha256.convert(utf8.encode(entry.password)).toString();
            passwordHashes[hash] = (passwordHashes[hash] ?? 0) + 1;
            if (passwordHashes[hash]! > 1) reused++;
          }

          final total = passwords.length;
          final weakPercent =
              total > 0 ? (weak / total * 100).toStringAsFixed(1) : '0';
          final mediumPercent =
              total > 0 ? (medium / total * 100).toStringAsFixed(1) : '0';
          final strongPercent =
              total > 0 ? (strong / total * 100).toStringAsFixed(1) : '0';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password Strength Distribution',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        if (weak > 0)
                          PieChartSectionData(
                            value: weak.toDouble(),
                            color: Colors.red,
                            title: '$weakPercent%',
                            radius: 50,
                            titleStyle: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        if (medium > 0)
                          PieChartSectionData(
                            value: medium.toDouble(),
                            color: Colors.yellow,
                            title: '$mediumPercent%',
                            radius: 50,
                            titleStyle: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                        if (strong > 0)
                          PieChartSectionData(
                            value: strong.toDouble(),
                            color: Colors.green,
                            title: '$strongPercent%',
                            radius: 50,
                            titleStyle: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Weak: $weak ($weakPercent%)',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                Text(
                  'Medium: $medium ($mediumPercent%)',
                  style: TextStyle(color: Colors.yellow, fontSize: 16),
                ),
                Text(
                  'Strong: $strong ($strongPercent%)',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Reused Passwords: $reused',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (weak > 0 || reused > 0) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/add_edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Fix Weak Passwords',
                        style: TextStyle(fontSize: 16)),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
