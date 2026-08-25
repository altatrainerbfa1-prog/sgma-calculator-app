import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

enum BsdPropType { residential, nonResidential }

class _Band {
  final double upTo; // Infinity represented as double.infinity
  final double rate;
  final String label;
  const _Band(this.upTo, this.rate, this.label);
}

const List<_Band> _residentialBands = [
  _Band(180000, 0.01, 'First S\$180,000'),
  _Band(360000, 0.02, 'Next S\$180,000'),
  _Band(1000000, 0.03, 'Next S\$640,000'),
  _Band(1500000, 0.04, 'Next S\$500,000'),
  _Band(3000000, 0.05, 'Next S\$1,500,000'),
  _Band(double.infinity, 0.06, 'Remainder above S\$3,000,000'),
];

const List<_Band> _nonResidentialBands = [
  _Band(180000, 0.01, 'First S\$180,000'),
  _Band(360000, 0.02, 'Next S\$180,000'),
  _Band(1000000, 0.03, 'Next S\$640,000'),
  _Band(1500000, 0.04, 'Next S\$500,000'),
  _Band(double.infinity, 0.05, 'Remainder above S\$1,500,000'),
];

class BsdScreen extends StatefulWidget {
  const BsdScreen({super.key});

  @override
  State<BsdScreen> createState() => _BsdScreenState();
}

class _BsdScreenState extends State<BsdScreen> {
  BsdPropType propType = BsdPropType.residential;
  final price = TextEditingController(text: '1500000');

  double totalBsd = 0;
  List<MapEntry<String, String>> breakdown = [];

  @override
  void initState() {
    super.initState();
    _calc();
  }

  void _calc() {
    final p = parseNum(price);
    final bands = propType == BsdPropType.residential ? _residentialBands : _nonResidentialBands;
    double remaining = p;
    double prevCap = 0;
    double total = 0;
    final rows = <MapEntry<String, String>>[];

    for (final band in bands) {
      final bandSize = band.upTo - prevCap;
      final taxable = ((p - prevCap).clamp(0, double.infinity))
          .clamp(0, bandSize == double.infinity ? double.infinity : bandSize)
          .toDouble();
      final duty = taxable * band.rate;
      total += duty;
      if (taxable > 0) {
        rows.add(MapEntry('${band.label} (${(band.rate * 100).toStringAsFixed(0)}%)', fmtCurrency(duty)));
      }
      prevCap = band.upTo;
      if (p <= band.upTo) break;
    }

    setState(() {
      totalBsd = total;
      breakdown = rows;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: "Buyer's Stamp Duty Calculator",
      form: Column(
        children: [
          DropField<BsdPropType>(
            label: 'Property type',
            value: propType,
            items: const [
              DropdownMenuItem(value: BsdPropType.residential, child: Text('Residential')),
              DropdownMenuItem(value: BsdPropType.nonResidential, child: Text('Non-residential')),
            ],
            onChanged: (v) {
              setState(() => propType = v ?? BsdPropType.residential);
              _calc();
            },
          ),
          NumberField(
            label: 'Purchase price or market value, whichever is higher (S\$)',
            controller: price,
            onChanged: (_) => _calc(),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _calc, child: const Text('CALCULATE')),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              "This calculates BSD only. If you're a foreigner, an entity, or purchasing an additional residential property, Additional Buyer's Stamp Duty (ABSD) may also apply on top of this.",
              style: TextStyle(fontSize: 12, color: SgmaColors.grey),
            ),
          ),
        ],
      ),
      results: ResultsPanel(
        headline: "Estimated Buyer's Stamp Duty",
        value: fmtCurrency(totalBsd),
        rows: breakdown,
        disclaimer:
            "Based on IRAS's BSD rates effective from 15 February 2023. Residential: 1% on the first S\$180,000, 2% on the next S\$180,000, 3% on the next S\$640,000, 4% on the next S\$500,000, 5% on the next S\$1,500,000, and 6% on the remainder. Non-residential: 1% on the first S\$180,000, 2% on the next S\$180,000, 3% on the next S\$640,000, 4% on the next S\$500,000, and 5% on the remainder above S\$1,500,000. Rates are set by IRAS and subject to change.",
      ),
    );
  }
}
