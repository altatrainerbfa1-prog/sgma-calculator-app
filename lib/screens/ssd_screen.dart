import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class SsdScreen extends StatefulWidget {
  const SsdScreen({super.key});

  @override
  State<SsdScreen> createState() => _SsdScreenState();
}

class _SsdScreenState extends State<SsdScreen> {
  final price = TextEditingController(text: '1200000');
  DateTime purchaseDate = DateTime(2024, 1, 15);
  DateTime saleDate = DateTime.now();

  double ssdAmount = 0;
  double ratePercent = 0;
  double holdingYears = 0;
  String regimeLabel = '';

  static final _newRegimeCutoff = DateTime(2025, 7, 4);

  @override
  void initState() {
    super.initState();
    _calc();
  }

  void _calc() {
    final p = parseNum(price);
    final holdingDays = saleDate.difference(purchaseDate).inDays;
    final years = holdingDays / 365.25;

    final isNewRegime = !purchaseDate.isBefore(_newRegimeCutoff);
    double rate;
    String regime;

    if (isNewRegime) {
      regime = '4-year regime (purchased on/after 4 Jul 2025)';
      if (years < 1) {
        rate = 0.16;
      } else if (years < 2) {
        rate = 0.12;
      } else if (years < 3) {
        rate = 0.08;
      } else if (years < 4) {
        rate = 0.04;
      } else {
        rate = 0;
      }
    } else {
      regime = '3-year regime (purchased 11 Mar 2017 - 3 Jul 2025)';
      if (years < 1) {
        rate = 0.12;
      } else if (years < 2) {
        rate = 0.08;
      } else if (years < 3) {
        rate = 0.04;
      } else {
        rate = 0;
      }
    }

    setState(() {
      holdingYears = years;
      ratePercent = rate;
      ssdAmount = p * rate;
      regimeLabel = regime;
    });
  }

  Future<void> _pickDate(bool isPurchase) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isPurchase ? purchaseDate : saleDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isPurchase) {
          purchaseDate = picked;
        } else {
          saleDate = picked;
        }
      });
      _calc();
    }
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: "Seller's Stamp Duty Calculator",
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumberField(label: 'Selling price (S\$)', controller: price, onChanged: (_) => _calc()),
          const Text('Purchase date',
              style: TextStyle(fontSize: 12.5, color: SgmaColors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          OutlinedButton(
            onPressed: () => _pickDate(true),
            child: Align(alignment: Alignment.centerLeft, child: Text(_fmtDate(purchaseDate))),
          ),
          const SizedBox(height: 16),
          const Text('Sale date',
              style: TextStyle(fontSize: 12.5, color: SgmaColors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          OutlinedButton(
            onPressed: () => _pickDate(false),
            child: Align(alignment: Alignment.centerLeft, child: Text(_fmtDate(saleDate))),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _calc, child: const Text('CALCULATE')),
          ),
        ],
      ),
      results: ResultsPanel(
        headline: "Estimated Seller's Stamp Duty",
        value: fmtCurrency(ssdAmount),
        rows: [
          MapEntry('Holding period', '${holdingYears.toStringAsFixed(1)} years'),
          MapEntry('Regime applied', regimeLabel),
          MapEntry('SSD rate', '${(ratePercent * 100).toStringAsFixed(0)}%'),
        ],
        disclaimer:
            "Properties purchased on or after 4 July 2025 fall under the 4-year SSD regime (16% / 12% / 8% / 4% by year of holding). Properties purchased between 11 March 2017 and 3 July 2025 fall under the 3-year regime (12% / 8% / 4%). SSD is 0% once the relevant holding period has passed. Rates are set by IRAS and subject to change.",
      ),
    );
  }
}
