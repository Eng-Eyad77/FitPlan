import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../l10n/l10n.dart';

/// A light check for instant feedback; the server checks again.
String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email) ? null : l10n.enterValidEmail;
}

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.label,
    this.newEmail = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? label;
  final bool newEmail;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: onSubmitted == null ? TextInputAction.next : TextInputAction.done,
      autofillHints: [newEmail ? AutofillHints.newUsername : AutofillHints.email],
      autocorrect: false,
      maxLength: 254,
      // an address reads left to right in Arabic too
      textDirection: TextDirection.ltr,
      style: AppText.body,
      decoration: InputDecoration(labelText: label ?? l10n.email, counterText: ''),
      validator: validateEmail,
      onFieldSubmitted: onSubmitted,
    );
  }
}

/// The 6-digit code from the email.
class EmailCodeField extends StatelessWidget {
  const EmailCodeField({super.key, required this.controller, this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: onSubmitted == null ? TextInputAction.next : TextInputAction.done,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
      textDirection: TextDirection.ltr,
      style: AppText.body,
      decoration: InputDecoration(labelText: l10n.emailCode, hintText: '123456'),
      validator: (value) => (value ?? '').length == 6 ? null : l10n.codeLength,
      onFieldSubmitted: onSubmitted,
    );
  }
}

/// "We sent a code to ...", with a new code and another email as ways out.
class CodeSentNote extends StatelessWidget {
  const CodeSentNote({
    super.key,
    required this.email,
    required this.onResend,
    required this.onChangeEmail,
  });

  final String email;

  /// null while busy
  final VoidCallback? onResend;
  final VoidCallback? onChangeEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.codeSentTo(signed(email)), style: AppText.body),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.checkSpam, style: AppText.caption),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            TextButton(onPressed: onResend, child: Text(l10n.resendCode)),
            TextButton(onPressed: onChangeEmail, child: Text(l10n.useAnotherEmail)),
          ],
        ),
      ],
    );
  }
}
