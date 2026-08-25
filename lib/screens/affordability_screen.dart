import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/common.dart';

enum PropType { private, hdbec }

class AffordabilityScreen extends StatefulWidget {
  const AffordabilityScreen({super.key});

  @override
  State<AffordabilityScreen> createState() => _AffordabilityScreenState();
}

class _AffordabilityScreenState extends State<AffordabilityScreen> {
  PropType propType = PropType.private;
  final income = TextEditingController(text: '12000');
  final debt = TextEditingController(text: '500');
  final tenor = TextEditingController(text: '25');

  double maxLoan = 0;
  double monthlyCap = 0;
  String limitApplied = '—';

  int get tenorCap => propType == PropType.hdbec ? 25 : 35;

  @override
  void initState() {
    super.initState();
    _calc();
  }

  void _calc() {
    final incomeV = parseNum(income);
    final debtV = parseNum(debt);
    var years = double.tryParse(tenor.text.trim()) ?? tenorCap.toDouble();
    if (years > tenorCap) {
      years = tenorCap.toDouble();
      tenor.text = tenorCap.toString();
    }
    if (years < 1) years = 1;

    const stressRate = 0.04;
    final r = stressRate / 12;
    final n = years * 12;

    final tdsrCap = incomeV * 0.55 - debtV;
    final msrCap = incomeV * 0.30;

    double cap;
    String limit;
    if (propType == PropType.hdbec) {
      cap = tdsrCap < msrCap ? tdsrCap : msrCap;
      limit = msrCap <= tdsrCap ? 'MSR (30% of income)' : 'TDSR (55% of income minus debt)';
    } else {
      cap = tdsrCap;
      limit = 'TDSR (55% of income minus debt)';
    }
    if (cap < 0) cap = 0;

    double loan;
    if (r == 0) {
      loan = cap * n;
    } else {
      final growth = math.pow(1 + r, n).toDouble();
      loan = cap * (growth - 1) / (r * growth);
    }

    setState(() {
      monthlyCap = cap;
      maxLoan = loan;
      limitApplied = limit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Affordability Calculator',
      form: Column(
        children: [
          DropField<PropType>(
            label: 'Property type',
            value: propType,
            items: const [
              DropdownMenuItem(value: PropType.private, child: Text('Private property / EC (resale)')),
              DropdownMenuItem(value: PropType.hdbec, child: Text('HDB flat / new EC (MSR applies)')),
            ],
            onChanged: (v) {
              setState(() => propType = v ?? PropType.private);
              _calc();
            },
          ),
          NumberField(label: 'Gross monthly income (S\$)', controller: income, onChanged: (_) => _calc()),
          NumberField(label: 'Other monthly debt (S\$)', controller: debt, onChanged: (_) => _calc()),
          NumberField(
            label: 'Loan tenure (years)',
            controller: tenor,
            helper: propType == PropType.hdbec
                ? 'Max 25 years for HDB / new EC loans.'
                : 'Max 35 years for private property / resale EC loans.',
            onChanged: (_) => _calc(),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _calc, child: const Text('CALCULATE')),
          ),
        ],
      ),
      results: ResultsPanel(
        headline: 'Estimated maximum loan amount',
        value: fmtCurrency(maxLoan),
        rows: [
          MapEntry('Max monthly instalment (at stress-test rate)', '${fmtCurrency(monthlyCap)} / mo'),
          MapEntry('Governing limit applied', limitApplied),
          const MapEntry('Stress-test rate used', '4.0% p.a.'),
        ],
        disclaimer:
            "Estimate only. Uses MAS's Total Debt Servicing Ratio (55% of gross monthly income) and, for HDB/EC purchases, the Mortgage Servicing Ratio (30% of gross monthly income), computed at the 4.0% medium-term stress-test rate banks are required to use. Your real eligibility depends on credit bureau records, other liabilities, and each bank's individual assessment.",
      ),
    );
  }
}
