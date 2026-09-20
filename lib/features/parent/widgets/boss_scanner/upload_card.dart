// /lib/features/parent/widgets/boss_scanner/upload_card.dart

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/theme/boss_theme.dart';

class UploadCard extends StatelessWidget {
  final BossGradTheme theme;
  final bool isProcessing;
  final int currentStep;

  final String? selectedGrade;
  final String? selectedSubject;
  final List<dynamic> grades;
  final List<dynamic> subjects;
  final List<dynamic> existingLevels;
  final String? selectedLevelId;
  final TextEditingController topicController;

  final List<XFile> selectedImages;
  final List<String> remoteImages; // <--- NEW: For retry mode
  final bool isRetryMode; // <--- NEW: For retry mode

  final ValueChanged<String> onGradeChanged;
  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String?> onLevelSelected;
  final Function(ImageSource) onPickImages;
  final VoidCallback onProcessImages;
  final VoidCallback onClearImages;

  const UploadCard({
    super.key,
    required this.theme,
    required this.isProcessing,
    required this.currentStep,
    required this.selectedGrade,
    required this.selectedSubject,
    required this.grades,
    required this.subjects,
    required this.existingLevels,
    required this.selectedLevelId,
    required this.topicController,
    required this.selectedImages,
    this.remoteImages = const [],
    this.isRetryMode = false,
    required this.onGradeChanged,
    required this.onSubjectChanged,
    required this.onLevelSelected,
    required this.onPickImages,
    required this.onProcessImages,
    required this.onClearImages,
  });

  @override
  Widget build(BuildContext context) {
    final gradeNames = grades.map((g) => g['name'].toString()).toList();
    final subjectNames = subjects.map((s) => s['name'].toString()).toList();
    final hasImages = selectedImages.isNotEmpty || remoteImages.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isRetryMode
              ? const Color(0xFFFFB3BD)
              : const Color(0xFFE5D9F4),
          width: 3,
        ),
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
                    isRetryMode ? 'RETRY MODE' : 'STEP 01',
                    style: TextStyle(
                      color: isRetryMode
                          ? const Color(0xFFFF6578)
                          : theme.primaryAction,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    isRetryMode ? 'Recover failed scan' : 'Scan textbook pages',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF241642),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Icon(
                isRetryMode ? LucideIcons.rotateCcw : LucideIcons.camera,
                color: isRetryMode
                    ? const Color(0xFFFF6578)
                    : theme.primaryAction,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 1. GRADE & SUBJECT SELECTORS
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  value: selectedGrade,
                  items: gradeNames,
                  hint: 'No Grades',
                  onChanged: (val) {
                    if (val != null && !isRetryMode) onGradeChanged(val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  value: selectedSubject,
                  items: subjectNames,
                  hint: 'No Subjects',
                  onChanged: (val) {
                    if (val != null && !isRetryMode) onSubjectChanged(val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. SLEEK PILLS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...existingLevels.map(
                  (level) => _buildLevelPill(
                    title: level['title'],
                    isActive: selectedLevelId == level['id'],
                    onTap: isRetryMode
                        ? () {}
                        : () => onLevelSelected(level['id']),
                  ),
                ),
                if (!isRetryMode)
                  _buildLevelPill(
                    title: '+ New Level',
                    isActive: selectedLevelId == null,
                    onTap: () => onLevelSelected(null),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. TOPIC INPUT
          if (selectedLevelId == null || isRetryMode)
            TextField(
              controller: topicController,
              enabled: !isRetryMode,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Topic Name (e.g. Fractions & Ratios)',
                hintStyle: const TextStyle(
                  color: Color(0xFFAAB1BF),
                  fontSize: 13,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFF7F8FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          const SizedBox(height: 18),

          // 4. UPLOAD DROP ZONE
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isRetryMode
                    ? const Color(0xFFFFF0F2)
                    : const Color(0xFFFBFAFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isRetryMode
                      ? const Color(0xFFFFD1D6)
                      : const Color(0xFFD8D3FA),
                  width: 2,
                ),
              ),
              child: hasImages
                  ? Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(8),
                            // Don't show "+" button if in retry mode
                            itemCount: isRetryMode
                                ? remoteImages.length
                                : selectedImages.length + 1,
                            itemBuilder: (context, index) {
                              if (!isRetryMode &&
                                  index == selectedImages.length) {
                                return GestureDetector(
                                  onTap: isProcessing
                                      ? null
                                      : () => onPickImages(ImageSource.gallery),
                                  child: Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEE8FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      LucideIcons.plus,
                                      color: theme.primaryAction,
                                    ),
                                  ),
                                );
                              }

                              return Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: isRetryMode
                                      ? Image.network(
                                          remoteImages[index],
                                          fit: BoxFit.cover,
                                        )
                                      : (kIsWeb
                                            ? Image.network(
                                                selectedImages[index].path,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(
                                                  selectedImages[index].path,
                                                ),
                                                fit: BoxFit.cover,
                                              )),
                                ),
                              );
                            },
                          ),
                        ),
                        if (!isProcessing && currentStep < 3)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: onProcessImages,
                                    icon: Icon(
                                      isRetryMode
                                          ? LucideIcons.rotateCcw
                                          : LucideIcons.wandSparkles,
                                      size: 14,
                                    ),
                                    label: Text(
                                      isRetryMode
                                          ? 'Retry AI Generation'
                                          : 'Generate Boss',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isRetryMode
                                          ? const Color(0xFFFF6578)
                                          : theme.primaryAction,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: onClearImages,
                                  icon: const Icon(
                                    LucideIcons.trash2,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6578),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEE8FF),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            LucideIcons.imagePlus,
                            color: theme.primaryAction,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Add pages to scan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF241642),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: isProcessing
                                  ? null
                                  : () => onPickImages(ImageSource.camera),
                              icon: const Icon(LucideIcons.camera, size: 15),
                              label: const Text(
                                'Camera',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryAction,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: isProcessing
                                  ? null
                                  : () => onPickImages(ImageSource.gallery),
                              icon: const Icon(LucideIcons.upload, size: 15),
                              label: const Text(
                                'Gallery',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF241642),
                                elevation: 0,
                                side: const BorderSide(
                                  color: Color(0xFFEADFF7),
                                  width: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(
                LucideIcons.sparkles,
                size: 15,
                color: isRetryMode
                    ? const Color(0xFFFF6578)
                    : theme.primaryAction,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isRetryMode
                      ? 'Reviewing a failed generation. Tap "Retry AI Generation" to attempt extraction again.'
                      : 'Pro tip: Use good lighting and keep the page flat for the best results.',
                  style: const TextStyle(
                    color: Color(0xFF756B91),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // (Keep _buildDropdown and _buildLevelPill identical to original)
  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value)
              ? value
              : (items.isNotEmpty ? items.first : null),
          hint: Text(
            hint,
            style: const TextStyle(color: Color(0xFFAAB1BF), fontSize: 13),
          ),
          isExpanded: true,
          icon: Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: theme.primaryAction,
          ),
          style: const TextStyle(
            color: Color(0xFF241642),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLevelPill({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFF5B8) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? const Color(0xFFE8CA57) : const Color(0xFFE5D9F4),
            width: 2,
          ),
          boxShadow: isActive
              ? const [
                  BoxShadow(color: Color(0xFFD1B63D), offset: Offset(0, 3)),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFF684E00) : const Color(0xFF697386),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
