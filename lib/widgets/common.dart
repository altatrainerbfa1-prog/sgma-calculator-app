import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Formats a number as Singapore-dollar currency, e.g. S$1,234,567.
String fmtCurrency(double n) {
  if (n.isNaN || n.isInfinite) return 'S\$0';
  final rounded = n.round().clamp(0, 999999999999);
  final s = rounded.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return 'S\$$buffer';
}

String fmtPercent(double fraction, {int decimals = 1}) {
  return '${(fraction * 100).toStringAsFixed(decimals)}%';
}

/// A labeled numeric text field matching the site's calculator inputs.
class NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? helper;
  final ValueChanged<String>? onChanged;

  const NumberField({
    super.key,
    required this.label,
    required this.controller,
    this.helper,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12.5, color: SgmaColors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            onChanged: onChanged,
          ),
          if (helper != null) ...[
            const SizedBox(height: 6),
            Text(helper!, style: const TextStyle(fontSize: 11.5, color: SgmaColors.grey)),
          ],
        ],
      ),
    );
  }
}

/// A labeled dropdown matching the site's calculator selects.
class DropField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? helper;

  const DropField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12.5, color: SgmaColors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
          ),
          if (helper != null) ...[
            const SizedBox(height: 6),
            Text(helper!, style: const TextStyle(fontSize: 11.5, color: SgmaColors.grey)),
          ],
        ],
      ),
    );
  }
}

/// The cream results panel used at the bottom of every calculator.
class ResultsPanel extends StatelessWidget {
  final String headline;
  final String value;
  final List<MapEntry<String, String>> rows;
  final String? flag;
  final String disclaimer;

  const ResultsPanel({
    super.key,
    required this.headline,
    required this.value,
    this.rows = const [],
    this.flag,
    required this.disclaimer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(headline, style: const TextStyle(fontSize: 13, color: SgmaColors.grey)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: SgmaColors.navy)),
            const SizedBox(height: 12),
            for (final row in rows)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: SgmaColors.line)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(row.key, style: const TextStyle(fontSize: 13, color: SgmaColors.grey)),
                    Text(row.value,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            if (flag != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EC),
                  border: Border.all(color: SgmaColors.goldLight),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(flag!, style: const TextStyle(fontSize: 12.5)),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: SgmaColors.line)),
              ),
              child: Text(disclaimer,
                  style: const TextStyle(fontSize: 11.5, color: SgmaColors.grey, height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class CalcScaffold extends StatelessWidget {
  final String title;
  final Widget form;
  final Widget results;

  const CalcScaffold({
    super.key,
    required this.title,
    required this.form,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            form,
            const SizedBox(height: 20),
            results,
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

double parseNum(TextEditingController c) {
  final v = double.tryParse(c.text.trim());
  return v ?? 0;
}
