import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final TextEditingController? controller;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    this.controller,
    this.obscureText = false,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? _errorText;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (!_hasInteracted && (widget.controller?.text.isNotEmpty ?? false)) {
      setState(() => _hasInteracted = true);
    }
    _validate();
  }

  void _validate() {
    if (!_hasInteracted) {
      setState(() => _errorText = null);
      return;
    }
    final value = widget.controller?.text ?? '';
    final error = widget.validator?.call(value);
    setState(() => _errorText = error);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (_errorText != null && _hasInteracted)
                  ? Colors.red
                  : theme.dividerColor,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              Icon(
                widget.icon,
                size: 16,
                color: (_errorText != null && _hasInteracted)
                    ? Colors.red
                    : (isDark ? Colors.white70 : const Color(0xFF757575)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  obscureText: widget.obscureText,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (_) => _onTextChanged(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF333333),
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: isDark ? Colors.white60 : const Color(0xFF999999),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    errorStyle: const TextStyle(fontSize: 0, height: 0),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_errorText != null && _hasInteracted) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _errorText!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}
