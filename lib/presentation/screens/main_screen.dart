import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/utils/math_utils.dart';
import '../providers/quadratic_provider.dart';
import 'result_screen.dart';
import '../widgets/action_buttons.dart';
import '../widgets/coefficient_input_field.dart';
import '../widgets/error_widget.dart';
import '../widgets/language_selector.dart';
import 'image_analysis_screen.dart';

/// Главный экран приложения
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final TextEditingController _aController;
  late final TextEditingController _bController;
  late final TextEditingController _cController;

  @override
  void initState() {
    super.initState();
    _aController = TextEditingController();
    _bController = TextEditingController();
    _cController = TextEditingController();
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _cController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('main.title'.tr()),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: LanguageSelector()),
          ),
        ],
      ),
      body: Consumer<QuadraticProvider>(
        builder: (context, provider, child) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'main.subtitle'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'main.equation_form'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  InfoWidget(
                    message: 'main.info_message'.tr(),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CoefficientInputField(
                            label: 'main.coefficient_a'.tr(),
                            controller: _aController,
                            onChanged: provider.setCoefficientA,
                            hintText: 'main.hint_a'.tr(),
                            errorText: provider.coefficientAError,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CoefficientInputField(
                            label: 'main.coefficient_b'.tr(),
                            controller: _bController,
                            onChanged: provider.setCoefficientB,
                            hintText: 'main.hint_b'.tr(),
                            errorText: provider.coefficientBError,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CoefficientInputField(
                            label: 'main.coefficient_c'.tr(),
                            controller: _cController,
                            onChanged: provider.setCoefficientC,
                            hintText: 'main.hint_c'.tr(),
                            errorText: provider.coefficientCError,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                          ),
                          if (_hasEquationPreview(provider)) ...[
                            const SizedBox(height: 20),
                            _buildEquationPreview(context, provider),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ActionButtons(
                    onSolve: provider.canSolve
                        ? () => _solve(context, provider)
                        : null,
                    onAnalyzeImage: () => _openImageAnalysis(context),
                    isLoading: provider.state == AppState1.solving,
                  ),
                  if (provider.state == AppState1.error && provider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    CustomErrorWidget(
                      message: provider.errorMessage!,
                      onRetry: provider.canSolve
                          ? () => _solve(context, provider)
                          : null,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEquationPreview(BuildContext context, QuadraticProvider provider) {
    final equation = provider.equationForAnalysis;
    if (equation == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'main.your_equation'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            equation,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  bool _hasEquationPreview(QuadraticProvider provider) {
    return provider.coefficientA.isNotEmpty &&
        provider.coefficientB.isNotEmpty &&
        provider.coefficientC.isNotEmpty &&
        MathUtils.tryParseCoefficient(provider.coefficientA) != null &&
        MathUtils.tryParseCoefficient(provider.coefficientB) != null &&
        MathUtils.tryParseCoefficient(provider.coefficientC) != null;
  }

  Future<void> _solve(
    BuildContext context,
    QuadraticProvider provider,
  ) async {
    await provider.solveEquation();

    final solution = provider.solution;
    if (!context.mounted || solution == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(solution: solution),
      ),
    );
  }

  Future<void> _openImageAnalysis(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ImageAnalysisScreen(),
      ),
    );
  }
}
