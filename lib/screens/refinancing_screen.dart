import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/common.dart';

class RefinancingScreen extends StatefulWidget {
  const RefinancingScreen({super.key});

  @override
  State<RefinancingScreen> createState() => _RefinancingScreenState();
}

class _RefinancingScreenState extends State<RefinancingScreen> {
  final outstanding = TextEditingController(text: '700000');
  final currentRate = TextEditingController(text: '3.5');
  final remainingTenor = TextEditingController(text: '22');
  final newRate = TextEditingController(text: '2.6');
  final costs = TextEditingController(text: '3000');

  double currentMonthly = 0;
  double newMonthly = 0;
  double monthlySavings = 0;
  double totalSavings = 0;
  double breakevenMonths = 0;

  @override
  void initState() {
    super.initState();
    _calc();
  }

  double _instalment(double p, double annualRate, double years) {
    final r = annualRate / 12;
    final n = years * 12;
    if (r == 0) return n > 0 ? p / n : 0;
    final growth = math.pow(1 + r, n).toDouble();
    return p * r * growth / (growth - 1);
  }

  void _calc() {
    final p = parseNum(outstanding);
    final years = double.tryParse(remainingTenor.text.trim()) ?? 20;
    final oneOffCosts = parseNum(costs);

    final curM = _instalment(p, parseNum(currentRate) / 100, years);
    final newM = _instalment(p, parseNum(newRate) / 100, years);
    final saveM = curM - newM;
    final totalSave = saveM * years * 12 - oneOffCosts;
    final breakeven = saveM > 0 ? oneOffCosts / saveM : 0;

    setState(() {
      currentMonthly = curM;
      newMonthly = newM;
      monthlySavings = saveM;
      totalSavings = totalSave;
      breakevenMonths = breakeven.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Refinancing Savings Calculator',
      form: Column(
        children: [
          NumberField(label: 'Outstanding loan balance (S\$)', controller: outstanding, onChanged: (_) => _calc()),
          NumberField(label: 'Current interest rate (% p.a.)', controller: currentRate, onChanged: (_) => _calc()),
          NumberField(label: 'Remaining tenure (years)', controller: remainingTenor, onChanged: (_) => _calc()),
          NumberField(label: 'New interest rate (% p.a.)', controller: newRate, onChanged: (_) => _calc()),
          NumberField(label: 'One-off refinancing costs (S\$)', controller: costs, onChanged: (_) => _calc()),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _calc, child: const Text('CALCULATE')),
          ),
        ],
      ),
      results: ResultsPanel(
        headline: 'Estimated monthly savings',
        value: '${fmtCurrency(monthlySavings)} / mo',
        rows: [
          MapEntry('Current monthly instalment', '${fmtCurrency(currentMonthly)} / mo'),
          MapEntry('New monthly instalment', '${fmtCurrency(newMonthly)} / mo'),
          MapEntry('Net savings over remaining tenure', fmtCurrency(totalSavings)),
          MapEntry('Breakeven period', breakevenMonths > 0 ? '${breakevenMonths.toStringAsFixed(1)} months' : '—'),
        ],
        disclaimer:
            'Estimate only, compares your current package against a new rate over your remaining tenure, net of one-off refinancing costs. Does not account for any lock-in penalties on your existing package.',
      ),
    );
  }
}
