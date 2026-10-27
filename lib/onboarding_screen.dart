import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'AppColors.dart';
import 'common_widgets.dart';
import 'finance_provider.dart';

/// First-run welcome: what the app does, then the three numbers it needs
/// before the dashboard means anything.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  final _nameCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();

  int _page = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _incomeCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish({bool withSample = false}) async {
    if (_submitting) return;
    setState(() => _submitting = true);

    await context.read<FinanceProvider>().completeOnboarding(
          name: _nameCtrl.text,
          monthlyIncome: double.tryParse(_incomeCtrl.text.trim()) ?? 0,
          savingsGoal: double.tryParse(_goalCtrl.text.trim()) ?? 0,
          withSampleData: withSample,
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(onStart: _goToSetup),
                  _SetupPage(
                    nameCtrl: _nameCtrl,
                    incomeCtrl: _incomeCtrl,
                    goalCtrl: _goalCtrl,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? cs.primary
                              : cs.onSurfaceVariant.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _submitting
                        ? null
                        : _page == 0
                            ? _goToSetup
                            : () => _finish(),
                    child: Text(_page == 0 ? 'เริ่มต้นใช้งาน' : 'เข้าสู่แอป'),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: _submitting ? null : () => _finish(withSample: true),
                    child: const Text('ดูตัวอย่างด้วยข้อมูลจำลองก่อน'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToSetup() {
    _pageCtrl.animateToPage(
      1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final VoidCallback onStart;
  const _WelcomePage({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 8),
      children: [
        Center(
          child: Container(
            width: 92,
            height: 92,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.heroGradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Text(
              '฿',
              style: TextStyle(
                color: AppColors.goldLight,
                fontSize: 48,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'รู้ว่าเงินหายไปไหน\nทุกบาททุกสตางค์',
          textAlign: TextAlign.center,
          style: context.tt.displaySmall?.copyWith(height: 1.3),
        ),
        const SizedBox(height: 10),
        Text(
          'บันทึกรายจ่ายใน 5 วินาที แล้วให้แอปสรุปให้ว่าเดือนนี้คุณใช้เงินเป็นอย่างไร',
          textAlign: TextAlign.center,
          style: context.tt.bodySmall?.copyWith(height: 1.55),
        ),
        const SizedBox(height: 30),
        const _Feature(
          icon: Icons.bolt_rounded,
          title: 'บันทึกเร็ว',
          message: 'เลือกหมวด ใส่จำนวนเงิน จบ ไม่ต้องกรอกอะไรเยอะ',
        ),
        const _Feature(
          icon: Icons.insights_rounded,
          title: 'เห็นภาพรวมทันที',
          message: 'กราฟรายวัน สัดส่วนหมวดหมู่ และคะแนนสุขภาพการเงิน',
        ),
        const _Feature(
          icon: Icons.lock_rounded,
          title: 'ข้อมูลอยู่ในเครื่องคุณ',
          message: 'ไม่มีบัญชีผู้ใช้ ไม่ต้องต่อเน็ต ไม่มีการส่งข้อมูลออกไปไหน',
        ),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _Feature({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: cs.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: context.tt.bodySmall?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupPage extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController incomeCtrl;
  final TextEditingController goalCtrl;

  const _SetupPage({
    required this.nameCtrl,
    required this.incomeCtrl,
    required this.goalCtrl,
  });

  @override
  Widget build(BuildContext context) {
    const numeric = TextInputType.numberWithOptions(decimal: true);
    final digitsOnly = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];

    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 8),
      children: [
        Text('ตั้งค่าเริ่มต้น', style: context.tt.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'ใส่ตัวเลขคร่าวๆ ก่อนก็ได้ แก้ทีหลังได้ตลอดในหน้าตั้งค่า',
          style: context.tt.bodySmall?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 26),
        TextField(
          controller: nameCtrl,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'เรียกคุณว่าอะไรดี',
            hintText: 'ชื่อเล่นก็ได้',
            prefixIcon: Icon(Icons.person_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: incomeCtrl,
          keyboardType: numeric,
          inputFormatters: digitsOnly,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'รายรับต่อเดือน',
            prefixText: '฿ ',
            prefixIcon: Icon(Icons.payments_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: goalCtrl,
          keyboardType: numeric,
          inputFormatters: digitsOnly,
          decoration: const InputDecoration(
            labelText: 'อยากเก็บเงินเดือนละเท่าไหร่',
            prefixText: '฿ ',
            prefixIcon: Icon(Icons.savings_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 22),
        AppCard(
          color: context.cs.surfaceContainer,
          child: Row(
            children: [
              Icon(
                Icons.shield_rounded,
                size: 18,
                color: context.cs.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ตัวเลขเหล่านี้เก็บไว้ในเครื่องของคุณเท่านั้น',
                  style: context.tt.bodySmall?.copyWith(height: 1.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
