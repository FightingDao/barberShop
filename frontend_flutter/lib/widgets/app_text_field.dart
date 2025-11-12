import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// 自定义输入框组件
/// 带有图标、标签和验证状态的输入框
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final bool enabled;
  final String? initialValue;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.initialValue,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  String? _errorText;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }

    if (widget.validator != null) {
      final error = widget.validator!(_controller.text);
      setState(() {
        _errorText = error;
        _hasError = error != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeSM,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
        ],
        TextFormField(
          controller: _controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: AppTheme.fontSizeBase,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _hasError ? AppTheme.error : AppTheme.textSecondary,
                    size: 20,
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixTap,
                    child: Icon(
                      widget.suffixIcon,
                      color: _hasError ? AppTheme.error : AppTheme.textSecondary,
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: widget.enabled ? Colors.white : AppTheme.bgSecondary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLG,
              vertical: AppTheme.spacingMD,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide(
                color: _hasError ? AppTheme.error : AppTheme.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide(
                color: _hasError ? AppTheme.error : AppTheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(color: AppTheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(color: AppTheme.error, width: 2),
            ),
          ),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: AppTheme.fontSizeBase,
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            _errorText!,
            style: const TextStyle(
              color: AppTheme.error,
              fontSize: AppTheme.fontSizeXS,
            ),
          ),
        ],
      ],
    );
  }
}