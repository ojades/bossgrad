import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DiagramRenderer extends StatelessWidget {
  final Map<String, dynamic>? diagram;

  const DiagramRenderer({super.key, this.diagram});

  @override
  Widget build(BuildContext context) {
    if (diagram == null) return const SizedBox.shrink();

    final type = diagram!['type'] as String;
    final data = diagram!['data'] as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEADFF7), width: 2),
      ),
      child: Center(child: _buildPuzzleShape(type, data)),
    );
  }

  Widget _buildPuzzleShape(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'triangle':
        return TrianglePuzzleWidget(data: data);
      case 'square':
        return SquarePuzzleWidget(data: data);
      case 'circle_cross':
        return CircleCrossPuzzleWidget(data: data);
      case 'sequence':
        return SequencePuzzleWidget(data: data);
      default:
        return const Text(
          'Analyze the pattern to solve!',
          style: TextStyle(
            color: Color(0xFF756B91),
            fontWeight: FontWeight.w600,
          ),
        );
    }
  }
}

// --- SHAPE WIDGETS ---

class TrianglePuzzleWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  const TrianglePuzzleWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PuzzleBox(value: data['top']),
        _VerticalConnector(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PuzzleBox(value: data['left']),
            _HorizontalConnector(),
            _PuzzleBox(value: data['center']),
            _HorizontalConnector(),
            _PuzzleBox(value: data['right']),
          ],
        ),
        _VerticalConnector(),
        _PuzzleBox(value: data['bottom']),
      ],
    );
  }
}

class SquarePuzzleWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  const SquarePuzzleWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PuzzleBox(value: data['top_left']),
            const SizedBox(width: 48),
            _PuzzleBox(value: data['top_right']),
          ],
        ),
        const SizedBox(height: 8),
        _PuzzleBox(value: data['center']),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PuzzleBox(value: data['bottom_left']),
            const SizedBox(width: 48),
            _PuzzleBox(value: data['bottom_right']),
          ],
        ),
      ],
    );
  }
}

class CircleCrossPuzzleWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  const CircleCrossPuzzleWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PuzzleBox(value: data['top'], isCircle: true),
        _VerticalConnector(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PuzzleBox(value: data['left'], isCircle: true),
            _HorizontalConnector(),
            _PuzzleBox(value: data['center'], isCircle: true),
            _HorizontalConnector(),
            _PuzzleBox(value: data['right'], isCircle: true),
          ],
        ),
        _VerticalConnector(),
        _PuzzleBox(value: data['bottom'], isCircle: true),
      ],
    );
  }
}

class SequencePuzzleWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  const SequencePuzzleWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Extract all items and filter out nulls
    final items = [
      data['item_1'],
      data['item_2'],
      data['item_3'],
      data['item_4'],
      data['item_5'],
    ].where((item) => item != null && item.toString().isNotEmpty).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PuzzleBox(value: entry.value),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    LucideIcons.arrowRight,
                    color: Color(0xFFC3B3EE),
                    size: 20,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// --- UTILITY COMPONENTS ---

class _PuzzleBox extends StatelessWidget {
  final dynamic value;
  final bool isCircle;

  const _PuzzleBox({required this.value, this.isCircle = false});

  @override
  Widget build(BuildContext context) {
    // If the data is completely missing, return an empty placeholder
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox(width: 48, height: 48);
    }

    final text = value.toString();
    final isUnknown = text == '?';

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isUnknown ? const Color(0xFFFFF5B8) : Colors.white,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(12),
        border: Border.all(
          color: isUnknown ? const Color(0xFFE8CA57) : const Color(0xFFEADFF7),
          width: 2,
        ),
        boxShadow: isUnknown
            ? const [BoxShadow(color: Color(0xFFD1B63D), offset: Offset(0, 3))]
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: isUnknown ? const Color(0xFFD89400) : const Color(0xFF241642),
        ),
      ),
    );
  }
}

class _VerticalConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 3, height: 16, color: const Color(0xFFEADFF7));
  }
}

class _HorizontalConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 16, height: 3, color: const Color(0xFFEADFF7));
  }
}
