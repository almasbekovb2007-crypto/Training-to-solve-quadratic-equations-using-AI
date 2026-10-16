import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Современный виджет поля ввода
class ModernInputField extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final String? errorText;
  final TextInputType keyboardType;
  final bool enabled;

  const ModernInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.errorText,
    this.keyboardType = TextInputType.number,
    this.enabled = true,
  });

  @override
  State<ModernInputField> createState() => _ModernInputFieldState();
}

class _ModernInputFieldState extends State<ModernInputField> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _borderColorAnimation;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _borderColorAnimation = ColorTween(
      begin: Colors.black12,
      end: AppTheme.primaryColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: _borderColorAnimation.value ?? Colors.grey,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              focusNode: _focusNode,
              enabled: widget.enabled,
              keyboardType: widget.keyboardType,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: widget.enabled ? Colors.black87 : Colors.black38,
              ),
              controller: TextEditingController(text: widget.value),
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hintText,
                errorText: widget.errorText,
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _borderColorAnimation.value,
                ),
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black38,
                ),
                errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.errorColor,
                ),
                contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
              ),
            ),
          ),
        );
      },
    );
  }
}
