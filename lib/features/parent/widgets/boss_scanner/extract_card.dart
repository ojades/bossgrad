// lib/features/parent/screens/widgets/boss_scanner/extract_card.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/theme/boss_theme.dart';

class ExtractCard extends StatelessWidget {
  final BossGradTheme theme;
  final int currentStep;
  final bool isProcessing;

  const ExtractCard({
    super.key,
    required this.theme,
    required this.currentStep,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentStep == 1
                        ? 'STEP 02 · WAITING'
                        : 'STEP 02 · OCR COMPLETE',
                    style: TextStyle(
                      color: theme.primaryAction,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    'Extracted text',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF241642),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              if (currentStep >= 2)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6FAF3),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        LucideIcons.check,
                        color: Color(0xFF16936F),
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '98% confidence',
                        style: TextStyle(
                          color: Color(0xFF16936F),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 23),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : currentStep == 3
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Content Read Successfully',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF241642),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Vision AI successfully parsed the textbook page and passed the content directly to the Gemini generation engine.',
                          style: TextStyle(
                            color: Color(0xFF756B91),
                            fontSize: 11,
                            height: 1.6,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.pencil, size: 14),
                          label: const Text(
                            'Edit raw text',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.primaryAction,
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        'Awaiting scan...',
                        style: TextStyle(
                          color: Color(0xFFAAB1BF),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
