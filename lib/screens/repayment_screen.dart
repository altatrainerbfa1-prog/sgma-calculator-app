import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/common.dart';

class RepaymentScreen extends StatefulWidget {
  const RepaymentScreen({super.key});

  @override
  State<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends State<RepaymentScreen> {
  final loanAmount = TextEditingController(text: '800000');
  final rate = TextEditingController(text: '2.6');
  final tenor = TextEditingController(text: '25');

  double monthly = 0;
  double totalInterest = 0;
  double totalRepayment = 0;

  @override
  void initState() {
    super.initState();
    _calc();
  }

  void _calc() {
    final p = parseNum(loanAmount);
    final annualRate = parseNum(rate) / 100;
    final years = double.tryParse(tenor.text.trim()) ?? 25;
    final r = annualRate / 12;
    final n = years * 12;

    double m;
    if (r == 0) {
      m = n > 0 ? p / n : 0;
    } else {
      final growth = math.pow(1 + r, n).toDouble();
      m = p * r * growth / (growth - 1);
    }

    setState(() {
      monthly = m;
      totalRepayment = m * n;
      totalInterest = totalRepayment - p;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Mortgage Repayment Calculator',
      form: Column(
        children: [
          NumberField(label: 'Loan amount (S\$)', controller: loanAmount, onChanged: (_) => _calc()),
          NumberField(label: 'Interest rate (% p.a.)', controller: rate, onChanged: (_) => _calc()),
          NumberField(label: 'Loan tenure (years)', controller: tenor, onChanged: (_) => _calc()),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _calc, child: const Text('CALCULATE')),
          ),
        ],
      ),
      results: ResultsPanel(
        headline: 'Estimated monthly instalment',
        value: '${fmtCurrency(monthly)} / mo',
        rows: [
          MapEntry('Total interest paid', fmtCurrency(totalInterest)),
          MapEntry('Total repayment over the loan', fmtCurrency(totalRepayment)),
        ],
        disclaimer:
            'Estimate only, based on a standard reducing-balance amortization schedule at a constant interest rate for the full tenure. Actual repayments will vary with rate changes, especially on SORA-pegged packages.',
      ),
    );
  }
}
