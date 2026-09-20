import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/theme/boss_theme.dart';

class GeneratedQuestionsCard extends StatelessWidget {
  final BossGradTheme theme;
  final List<dynamic> generatedQuestions;
  final bool isProcessing;
  final Function(int) onDelete;
  final VoidCallback onDeploy;

  const GeneratedQuestionsCard({
    super.key,
    required this.theme,
    required this.generatedQuestions,
    required this.isProcessing,
    required this.onDelete,
    required this.onDeploy,
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
                    'STEP 03 · AI GENERATED',
                    style: TextStyle(
                      color: theme.primaryAction,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Battle questions',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF241642),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEE8FF),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          '${generatedQuestions.length} questions',
                          style: TextStyle(
                            color: theme.primaryAction,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // GENERATED QUESTIONS LIST
          ...generatedQuestions.asMap().entries.map((entry) {
            int idx = entry.key;
            Map<String, dynamic> q = entry.value;
            final options = q['options'] as List<dynamic>? ?? [];
            final diagramSvg = q['diagram_svg'] as String?;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE7EAF0))),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '0${idx + 1}',
                    style: TextStyle(
                      color: theme.primaryAction,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q['question'] ??
                              q['question_text'] ??
                              'Unknown Question',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF241642),
                          ),
                        ),

                        // ---> 1. RENDER MAIN DIAGRAM (If exists)
                        if (diagramSvg != null)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            height:
                                60, // Small preview size for the parent summary
                            alignment: Alignment.centerLeft,
                            child: SvgPicture.string(diagramSvg),
                          ),

                        const SizedBox(height: 8),

                        // ---> 2. RENDER POLYMORPHIC OPTIONS
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: options.asMap().entries.map((opt) {
                            final prefix =
                                '${String.fromCharCode(65 + opt.key)} · ';

                            // Check if option uses the new polymorphic dictionary format
                            if (opt.value is Map) {
                              final optionData =
                                  opt.value as Map<String, dynamic>;
                              final type = optionData['type'] ?? 'text';
                              final value =
                                  optionData['value']?.toString() ?? '';

                              if (type == 'svg') {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      prefix,
                                      style: const TextStyle(
                                        color: Color(0xFF697386),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          24, // Constrain SVG options nicely
                                      child: SvgPicture.string(value),
                                    ),
                                  ],
                                );
                              }
                              // Fallback for 'text' dictionary
                              return Text(
                                '$prefix$value',
                                style: const TextStyle(
                                  color: Color(0xFF697386),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }

                            // Legacy fallback (if AI returned a flat string array)
                            return Text(
                              '$prefix${opt.value}',
                              style: const TextStyle(
                                color: Color(0xFF697386),
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.trash2,
                      size: 14,
                      color: Color(0xFF697386),
                    ),
                    onPressed: () => onDelete(idx),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 21),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isProcessing ? null : onDeploy,
              style:
                  ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF172033),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ).copyWith(
                    side: WidgetStateProperty.all(
                      const BorderSide(color: Color(0xFF090D15), width: 0),
                    ),
                  ),
              child: isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.gamepad2,
                          size: 18,
                          color: Color(0xFFA99CFF),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Deploy boss battle to map',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(LucideIcons.arrowRight, size: 16),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
