import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

enum OtherLoans { none, one, twoPlus }

class EquityTermLoanScreen extends StatefulWidget {
  const EquityTermLoanScreen({super.key});

  @override
  State<EquityTermLoanScreen> createState() => _EquityTermLoanScreenState();
}

class _EquityTermLoanScreenState extends State<EquityTermLoanScreen> {
  final propValue = TextEditingController(text: '1800000');
  final outstanding = TextEditingController(text: '600000');
  OtherLoans otherLoans = OtherLoans.none;
  final cpfUsed = TextEditingController(text: '150000');
  final income = TextEditingController(text: '15000');
  final tenor = TextEditingController(text: '20');

  double finalCash = 0;
  double equityCap = 0;
  double resultingLtv = 0;
  double ltvTier = 0.75;
  String limitApplied = '—';
  bool showTdsrFlag = false;

  @override
  void initState() {
    super.initState();
    _calc();
  }

  double get _ltvTierValue {
    switch (otherLoans) {
      case OtherLoans.none:
        return 0.75;
      case OtherLoans.one:
        return 0.45;
      case OtherLoans.twoPlus:
        return 0.35;
    }
  }

  void _calc() {
    final propValueV = parseNum(propValue);
    final outstandingV = parseNum(outstanding);
    final cpfUsedV = parseNum(cpfUsed);
    final incomeV = parseNum(income);
    final years = double.tryParse(tenor.text.trim()) ?? 20;
    final tier = _ltvTierValue;

    final maxTotalLoan = propValueV * tier;
    final equityBeforeCpf = (maxTotalLoan - outstandingV).clamp(0, double.infinity).toDouble();
    final equityCapV = (equityBeforeCpf - cpfUsedV).clamp(0, double.infinity).toDouble();

    double ltv = propValueV > 0 ? (outstandingV + equityCapV) / propValueV : 0;

    double cash = equityCapV;
    String limit = 'Equity ceiling (LTV − CPF used)';
    bool showFlag = false;

    if (ltv > 0.50) {
      showFlag = true;
      const stressRate = 0.04;
      final r = stressRate / 12;
      final n = years * 12;
      final tdsrCap = (incomeV * 0.55).clamp(0, double.infinity).toDouble();
      double tdsrMaxLoan;
      if (r == 0) {
        tdsrMaxLoan = tdsrCap * n;
      } else {
        final growth = math.pow(1 + r, n).toDouble();
        tdsrMaxLoan = tdsrCap * (growth - 1) / (r * growth);
      }
      final tdsrCash = (tdsrMaxLoan - outstandingV).clamp(0, double.infinity).toDouble();
      if (tdsrCash < cash) {
        cash = tdsrCash;
        limit = 'TDSR (55% of income, at 4.0% stress rate)';
      }
      ltv = propValueV > 0 ? (outstandingV + cash) / propValueV : 0;
    }

    setState(() {
      finalCash = cash;
      equityCap = equityCapV.toDouble();
      resultingLtv = ltv;
      ltvTier = tier;
      limitApplied = limit;
      showTdsrFlag = showFlag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Equity Term Loan Calculator',
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: SgmaColors.cream,
              border: Border.all(color: SgmaColors.line),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Private residential and commercial property only. Not available for HDB flats.',
              style: TextStyle(fontSize: 12.5, color: SgmaColors.ink, fontWeight: FontWeight.w500),
            ),
          ),
          NumberField(
              label: 'Current property value (bank valuation or market estimate, S\$)',
              controller: propValue,
              onChanged: (_) => _calc()),
          NumberField(
              label: 'Outstanding mortgage balance on this property (S\$)',
              controller: outstanding,
              onChanged: (_) => _calc()),
          DropField<OtherLoans>(
            label: 'Other outstanding housing loans (across all properties)',
            value: otherLoans,
            items: const [
              DropdownMenuItem(value: OtherLoans.none, child: Text('None — this is my only property loan')),
              DropdownMenuItem(value: OtherLoans.one, child: Text('1 other outstanding housing loan')),
              DropdownMenuItem(value: OtherLoans.twoPlus, child: Text('2 or more other outstanding housing loans')),
            ],
            onChanged: (v) {
              setState(() => otherLoans = v ?? OtherLoans.none);
              _calc();
            },
            helper: 'Sets your LTV ceiling at ${(_ltvTierValue * 100).toStringAsFixed(0)}% of property value.',
          ),
          NumberField(
            label: 'CPF principal + accrued interest used on this property (S\$)',
            controller: cpfUsed,
            helper: "Equity funded by CPF isn't available for cash withdrawal.",
            onChanged: (_) => _calc(),
          ),
          NumberField(label: 'Gross monthly income (S\$)', controller: income, onChanged: (_) => _calc()),
          NumberField(
              label: 'Loan tenure for the equity term loan (years)', controller: tenor, onChanged: (_) => _calc()),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _calc, child: const Text('CALCULATE')),
          ),
        ],
      ),
      results: ResultsPanel(
        headline: 'Estimated cash you may be able to unlock',
        value: fmtCurrency(finalCash),
        rows: [
          MapEntry('Equity-based ceiling (before TDSR)', fmtCurrency(equityCap)),
          MapEntry('Resulting loan-to-value after withdrawal', fmtPercent(resultingLtv)),
          MapEntry('LTV ceiling applied', '${(ltvTier * 100).toStringAsFixed(0)}%'),
          MapEntry('Governing limit', limitApplied),
        ],
        flag: showTdsrFlag
            ? "Because the resulting LTV is above 50%, MAS requires this loan to also be assessed under TDSR (55% of gross monthly income, at the 4.0% stress-test rate). Whichever of the equity ceiling or the TDSR limit is lower is what's shown above."
            : null,
        disclaimer:
            "Estimate only. Uses MAS's loan-to-value limits for mortgage equity withdrawal loans (75% / 45% / 35% of property value depending on other outstanding housing loans), the CPF exclusion rule, and, where resulting LTV exceeds 50%, TDSR (55% of gross monthly income at the 4.0% stress-test rate). Does not account for other existing debt obligations, which would reduce your actual TDSR room. Your real eligibility depends on the bank's valuation, credit assessment, and your full financial profile.",
      ),
    );
  }
}
