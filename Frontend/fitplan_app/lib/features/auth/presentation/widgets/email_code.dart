import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
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
    this.live = false,
  });

  final TextEditingController controller;
  final String? label;
  final bool newEmail;
  final ValueChanged<String>? onSubmitted;

  /// Checks this field as soon as it's typed in, without marking the other fields.
  final bool live;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autovalidateMode: live ? AutovalidateMode.onUserInteraction : null,
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

/// The 6-digit code from the email, drawn as six boxes. Underneath is one ordinary field, invisible,
/// so typing, pasting, iOS code autofill and the form's validation work as usual.
class EmailCodeField extends StatefulWidget {
  const EmailCodeField({super.key, required this.controller, this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;

  static const length = 6;
  static const _boxHeight = 58.0;

  @override
  State<EmailCodeField> createState() => _EmailCodeFieldState();
}

class _EmailCodeFieldState extends State<EmailCodeField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  Widget _box(String code, int index) {
    final filled = index < code.length;
    final current = _focus.hasFocus && index == code.length.clamp(0, EmailCodeField.length - 1);
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: EmailCodeField._boxHeight,
        margin: EdgeInsetsDirectional.only(start: index == 0 ? 0 : AppSpacing.sm),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: current ? AppColors.accent : AppColors.border, width: current ? 1.5 : 1),
        ),
        child: filled
            ? Text(code[index], style: AppText.title)
            : current
                ? Container(width: 14, height: 2, color: AppColors.accent)
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.controller, _focus]),
      builder: (context, _) => Stack(
        children: [
          Semantics(
            label: l10n.emailCode,
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focus,
              keyboardType: TextInputType.number,
              textInputAction: widget.onSubmitted == null ? TextInputAction.next : TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(EmailCodeField.length),
              ],
              showCursor: false,
              enableInteractiveSelection: false,
              style: const TextStyle(color: Colors.transparent, height: 1),
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                // as tall as the boxes, so a validation message shows under them
                contentPadding: EdgeInsets.symmetric(vertical: EmailCodeField._boxHeight / 2 - 7),
              ),
              validator: (value) => (value ?? '').length == EmailCodeField.length ? null : l10n.codeLength,
              onFieldSubmitted: widget.onSubmitted,
            ),
          ),
          // taps go through to the field
          IgnorePointer(
            child: Directionality(
              // digits read left to right in Arabic too
              textDirection: TextDirection.ltr,
              child: Row(
                children: [for (var i = 0; i < EmailCodeField.length; i++) _box(widget.controller.text, i)],
              ),
            ),
          ),
        ],
      ),
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
