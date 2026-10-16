import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/solution_result.dart';

/// Экран пошагового решения
class StepByStepScreen extends StatelessWidget {
  final SolutionResult solution;

  const StepByStepScreen({
    super.key,
    required this.solution,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('step_by_step.title'.tr()),
        actions: [
          IconButton(
            onPressed: () => _copySolution(context),
            icon: const Icon(Icons.copy),
            tooltip: 'common.copy'.tr(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Информационная карточка
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'step_by_step.info_message'.tr(),
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Шаги решения
            ..._buildSteps(),
            
            const SizedBox(height: 24),
            
            // Итоговый результат
            _buildResultCard(),
            
            const SizedBox(height: 24),
            
            // Кнопки действий
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('step_by_step.back'.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _copySolution(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('common.copy'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Построение шагов решения
  List<Widget> _buildSteps() {
    final sections = _buildLocalizedSections();
    final widgets = <Widget>[];
    
    for (int i = 0; i < sections.length; i++) {
      widgets.add(_buildStepCard(i + 1, sections[i].title, sections[i].content));
      
      if (i < sections.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    
    return widgets;
  }

  /// Построение карточки шага
  Widget _buildStepCard(int stepNumber, String title, String content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      stepNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_StepSection> _buildLocalizedSections() {
    final sections = <_StepSection>[
      _StepSection(
        title: tr('steps.discriminant_formula'),
        content: solution.steps.length > 1 ? solution.steps[1] : 'D = b² - 4ac',
      ),
      _StepSection(
        title: tr('steps.substitution'),
        content: solution.steps.length > 3 ? solution.steps[3] : 'D = b² - 4ac',
      ),
      _StepSection(
        title: tr('steps.calculation'),
        content: _buildCalculationBlock(),
      ),
      _StepSection(
        title: tr('steps.analysis'),
        content: _buildAnalysisText(),
      ),
    ];

    final rootsBlock = _buildRootsBlock();
    if (rootsBlock.isNotEmpty) {
      sections.add(
        _StepSection(
          title: tr('steps.roots_calculation'),
          content: rootsBlock,
        ),
      );
    }

    return sections;
  }

  String _buildCalculationBlock() {
    final lines = <String>[];
    if (solution.steps.length > 5) {
      lines.add(solution.steps[5]);
    }
    if (solution.steps.length > 6) {
      lines.add(solution.steps[6]);
    } else {
      lines.add('D = ${_formatDouble(solution.discriminant)}');
    }
    return lines.join('\n');
  }

  String _buildAnalysisText() {
    switch (solution.type) {
      case SolutionType.twoRealRoots:
        return 'D > 0: ${tr('result.two_roots')}';
      case SolutionType.oneRealRoot:
        return 'D = 0: ${tr('result.one_root')}';
      case SolutionType.noRealRoots:
        return 'D < 0: ${tr('result.no_roots')}';
    }
  }

  String _buildRootsBlock() {
    if (solution.type == SolutionType.noRealRoots) {
      return tr('result.no_roots');
    }

    final rootLines = solution.steps
        .where((step) => step.trimLeft().startsWith('x'))
        .toList();

    if (rootLines.isNotEmpty) {
      return rootLines.join('\n');
    }

    return solution.rootsDescription;
  }

  /// Построение карточки с результатом
  Widget _buildResultCard() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 12),
                Text(
                  'step_by_step.final_result'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${tr('result.solution_type')}: ${solution.typeDescription}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${tr('result.discriminant')}: D = ${_formatDouble(solution.discriminant)}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    solution.rootsDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copySolution(BuildContext context) {
    final buffer = StringBuffer();
    final sections = _buildLocalizedSections();
    for (final section in sections) {
      buffer.writeln(section.title);
      buffer.writeln(section.content);
      buffer.writeln();
    }
    buffer.writeln('${tr('step_by_step.final_result')}: ${solution.rootsDescription}');

    Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('common.copied'.tr())),
    );
  }

  /// Форматирование числа для вывода
  String _formatDouble(double value) {
    if (value.abs() < 0.000001) return '0';
    if (value == value.truncate()) {
      return value.truncate().toString();
    }
    return value.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

class _StepSection {
  final String title;
  final String content;

  const _StepSection({
    required this.title,
    required this.content,
  });
}
