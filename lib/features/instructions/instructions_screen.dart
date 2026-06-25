import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

class InstructionsScreen extends StatefulWidget {
  final bool fromMenu;

  const InstructionsScreen({super.key, this.fromMenu = false});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  final PageController _ctrl = PageController();
  int _page = 0;

  static const _pages = [
    _InstructionPage(
      icon: Icons.open_with_rounded,
      titleFa: 'جابه‌جا کردن اشیاء',
      bodyFa:
          'اشیاء روی صحنه را با انگشت بکش و جابه‌جا کن.\nبرخی اشیاء وقتی به جای درست برسند، به آنجا می‌چسبند.',
    ),
    _InstructionPage(
      icon: Icons.rotate_right_rounded,
      titleFa: 'چرخش اشیاء',
      bodyFa:
          'اشیاء قابل چرخش را با یک ضربه (تپ) بچرخان.\nهر بار ۴۵ درجه می‌چرخند تا زاویه درست را پیدا کنی.',
    ),
    _InstructionPage(
      icon: Icons.visibility_rounded,
      titleFa: 'کشف سرنخ',
      bodyFa:
          'وقتی اشیاء در چیدمان درست قرار بگیرند،\nیک سرنخ پنهان آشکار می‌شود — دنباله نمادها را به یاد بسپار.',
    ),
    _InstructionPage(
      icon: Icons.grid_view_rounded,
      titleFa: 'وارد کردن کد',
      bodyFa:
          'نمادها را به ترتیبی که کشف کردی\nروی کیپد نمادین پایین صفحه وارد کن.',
    ),
    _InstructionPage(
      icon: Icons.lightbulb_outline_rounded,
      titleFa: 'راهنمایی',
      bodyFa:
          'اگر گیر کردی، دکمه راهنما در بالای صفحه را بزن.\nیک سرنخ متنی دریافت می‌کنی — نه پاسخ مستقیم!',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('راهنما',
            style: TextStyle(fontFamily: AppFonts.body, color: AppColors.ink)),
        iconTheme: const IconThemeData(color: AppColors.ink),
        actions: [
          if (!isLast)
            TextButton(
              onPressed: () => context.go('/menu'),
              child: const Text('رد شدن',
                  style: TextStyle(color: AppColors.muted, fontSize: 13)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Page indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.accent : AppColors.muted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Page content
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (p) => setState(() => _page = p),
              itemCount: _pages.length,
              itemBuilder: (_, i) => _PageContent(page: _pages[i]),
            ),
          ),

          // Navigation
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 40),
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor:
                    isLast ? AppColors.accent : AppColors.ink,
              ),
              child: Text(
                isLast ? 'شروع بازی' : 'بعدی',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionPage {
  final IconData icon;
  final String titleFa;
  final String bodyFa;

  const _InstructionPage({
    required this.icon,
    required this.titleFa,
    required this.bodyFa,
  });
}

class _PageContent extends StatelessWidget {
  final _InstructionPage page;

  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 1.5),
            ),
            child: Icon(page.icon, color: AppColors.accent, size: 48),
          ),
          const SizedBox(height: 36),
          Text(
            page.titleFa,
            style: const TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 26,
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page.bodyFa,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 16,
              color: AppColors.ink,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
