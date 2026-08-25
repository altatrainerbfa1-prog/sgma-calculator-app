import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/affordability_screen.dart';
import 'screens/repayment_screen.dart';
import 'screens/refinancing_screen.dart';
import 'screens/bsd_screen.dart';
import 'screens/ssd_screen.dart';
import 'screens/equity_term_loan_screen.dart';

void main() {
  runApp(const SgmaApp());
}

class SgmaApp extends StatelessWidget {
  const SgmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Singapore Mortgage Advisory',
      debugShowCheckedModeBanner: false,
      theme: buildSgmaTheme(),
      home: const HomeScreen(),
    );
  }
}

class _CalcItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
  const _CalcItem(this.title, this.subtitle, this.icon, this.builder);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_CalcItem>[
      _CalcItem(
        'Affordability',
        'How much you may be eligible to borrow, under TDSR / MSR.',
        Icons.calculate_outlined,
        (_) => const AffordabilityScreen(),
      ),
      _CalcItem(
        'Mortgage Repayment',
        'Monthly instalment, total interest, and total repayment.',
        Icons.payments_outlined,
        (_) => const RepaymentScreen(),
      ),
      _CalcItem(
        'Refinancing Savings',
        'Monthly and total savings, plus your breakeven period.',
        Icons.swap_horiz_outlined,
        (_) => const RefinancingScreen(),
      ),
      _CalcItem(
        "Buyer's Stamp Duty",
        'BSD payable, residential or non-residential.',
        Icons.receipt_long_outlined,
        (_) => const BsdScreen(),
      ),
      _CalcItem(
        "Seller's Stamp Duty",
        'SSD payable based on your holding period.',
        Icons.description_outlined,
        (_) => const SsdScreen(),
      ),
      _CalcItem(
        'Equity Term Loan',
        'Cash you may be able to unlock from your property.',
        Icons.home_work_outlined,
        (_) => const EquityTermLoanScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: SgmaColors.cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: SgmaColors.navy,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SINGAPORE MORTGAGE ADVISORY',
                        style: TextStyle(
                            color: SgmaColors.goldLight,
                            fontSize: 11,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    const Text('Mortgage & property\ncalculators',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.2)),
                    const SizedBox(height: 8),
                    Text('Six tools, all built on current IRAS and MAS figures.',
                        style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 13.5)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: SgmaColors.navy,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(item.icon, color: SgmaColors.goldLight, size: 22),
                        ),
                        title: Text(item.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(item.subtitle,
                              style: const TextStyle(fontSize: 12.5, color: SgmaColors.grey)),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: SgmaColors.grey),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: item.builder),
                          );
                        },
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
