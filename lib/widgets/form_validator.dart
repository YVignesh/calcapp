import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Specification for a single validated field.
class FieldSpec {
  final TextEditingController controller;
  final String label;
  final bool required;
  final double? min;
  final double? max;
  final bool allowZero;
  final bool integerOnly;
  final String? Function(String raw)? custom;

  const FieldSpec({
    required this.controller,
    required this.label,
    this.required = true,
    this.min,
    this.max,
    this.allowZero = false,
    this.integerOnly = false,
    this.custom,
  });
}

/// Validates a list of [FieldSpec]s. On success returns true. On failure:
/// - Populates [onErrors] with a map of controller → error message.
/// - Shows a consolidated SnackBar listing the issues.
/// - Focuses the first invalid field.
/// Returns false.
class FormValidator {
  static bool run(
    BuildContext context,
    List<FieldSpec> specs, {
    required void Function(Map<TextEditingController, String>) onErrors,
  }) {
    final errors = <TextEditingController, String>{};
    TextEditingController? firstInvalid;

    for (final spec in specs) {
      final raw = spec.controller.text.trim();

      // Required / empty check.
      if (raw.isEmpty) {
        if (spec.required) {
          errors[spec.controller] = '${spec.label} is required';
          firstInvalid ??= spec.controller;
        }
        continue;
      }

      // Numeric parse.
      final value = double.tryParse(raw.replaceAll(',', ''));
      if (value == null) {
        errors[spec.controller] = '${spec.label} must be a number';
        firstInvalid ??= spec.controller;
        continue;
      }

      // Integer check.
      if (spec.integerOnly && value != value.truncateToDouble()) {
        errors[spec.controller] = '${spec.label} must be a whole number';
        firstInvalid ??= spec.controller;
        continue;
      }

      // Zero check.
      if (!spec.allowZero && value == 0) {
        errors[spec.controller] = '${spec.label} cannot be zero';
        firstInvalid ??= spec.controller;
        continue;
      }

      // Min bound.
      if (spec.min != null && value < spec.min!) {
        errors[spec.controller] =
            '${spec.label} must be ≥ ${spec.min}';
        firstInvalid ??= spec.controller;
        continue;
      }

      // Max bound.
      if (spec.max != null && value > spec.max!) {
        errors[spec.controller] =
            '${spec.label} must be ≤ ${spec.max}';
        firstInvalid ??= spec.controller;
        continue;
      }

      // Custom validator.
      if (spec.custom != null) {
        final msg = spec.custom!(raw);
        if (msg != null) {
          errors[spec.controller] = msg;
          firstInvalid ??= spec.controller;
          continue;
        }
      }
    }

    if (errors.isNotEmpty) {
      onErrors(errors);
      // Show consolidated snack.
      final messages = errors.values.toList();
      final snackText = messages.length == 1
          ? messages.first
          : '${messages.length} fields need attention: ${messages.first}…';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            snackText,
            style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      // Focus first invalid field.
      if (firstInvalid != null) {
        firstInvalid.selection = TextSelection.fromPosition(
          TextPosition(offset: firstInvalid.text.length),
        );
      }
      return false;
    }

    // All valid — clear any stale errors.
    onErrors({});
    return true;
  }
}

/// A [TextField] wrapper that wires [errorText] from [FormValidator].
class ValidatedField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;

  const ValidatedField({
    super.key,
    required this.controller,
    this.errorText,
    required this.decoration,
    this.keyboardType,
    this.onChanged,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType ??
          const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      decoration: decoration.copyWith(
        errorText: errorText?.isNotEmpty == true ? errorText : null,
      ),
    );
  }
}
