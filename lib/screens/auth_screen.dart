import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation.dart';
import '../state/app_state.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_layout.dart';
import '../theme/pm_text.dart';
import '../widgets/pm_button.dart';
import '../widgets/pm_primitives.dart';

/// 03 — Connexion ESP. Student account or guest mode.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_rebuild);
    _passwordFocus.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _signIn() {
    final email = _email.text.trim();
    // No backend yet: any non-empty ESP address opens a student session.
    if (email.isEmpty) {
      _emailFocus.requestFocus();
      return;
    }
    context.read<AppState>().signIn(email);
    PmNav.enterHome(context);
  }

  void _guest() {
    context.read<AppState>().continueAsGuest();
    PmNav.enterHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: PmPage(
        maxWidth: PmLayout.launchMaxWidth,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(26, pad.top + 48, 26, pad.bottom + 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height - pad.top - pad.bottom - 60,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Se connecter',
                    style: PmText.grotesk(28, weight: FontWeight.w700, color: pm.ink, ls: -0.02)),
                const SizedBox(height: 6),
                Text(
                  'Avec votre compte ESP pour retrouver votre emploi du temps et vos favoris.',
                  style: PmText.sans(14, color: pm.ink2, height: 1.5),
                ),
                const SizedBox(height: 30),
                const PmSectionLabel('Adresse ESP', size: 9.5, ls: 0.14, bottom: 7),
                _Field(
                  controller: _email,
                  focusNode: _emailFocus,
                  hint: 'prenom.nom@esp.sn',
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const <String>[AutofillHints.email],
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: 12),
                const PmSectionLabel('Mot de passe', size: 9.5, ls: 0.14, bottom: 7),
                _Field(
                  controller: _password,
                  focusNode: _passwordFocus,
                  hint: '••••••••',
                  obscure: !_showPassword,
                  autofillHints: const <String>[AutofillHints.password],
                  onSubmitted: (_) => _signIn(),
                  trailing: GestureDetector(
                    onTap: () => setState(() => _showPassword = !_showPassword),
                    child: Text(
                      _showPassword ? 'Masquer' : 'Afficher',
                      style: PmText.sans(12.5, weight: FontWeight.w600, color: pm.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Mot de passe oublié ?',
                      style: PmText.sans(12.5, weight: FontWeight.w600, color: pm.blue)),
                ),
                const SizedBox(height: 22),
                PmButton(label: 'Se connecter', height: 54, fontSize: 16, onTap: _signIn),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    children: <Widget>[
                      const Expanded(child: PmDivider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OU', style: PmText.mono(10, color: pm.ink2, ls: 0.12)),
                      ),
                      const Expanded(child: PmDivider()),
                    ],
                  ),
                ),
                PmButton(
                  label: 'Continuer en visiteur',
                  variant: PmButtonVariant.secondary,
                  onTap: _guest,
                ),
                const Spacer(),
                const SizedBox(height: 24),
                Text(
                  "Le mode visiteur donne accès à la carte et aux itinéraires, sans emploi du temps.",
                  textAlign: TextAlign.center,
                  style: PmText.sans(11.5, color: pm.ink2, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.autofillHints,
    this.onSubmitted,
    this.trailing,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final focused = focusNode.hasFocus;
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: pm.surf,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: focused ? pm.blue : pm.line, width: focused ? 1.5 : 1),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscure,
              keyboardType: keyboardType,
              autofillHints: autofillHints,
              onSubmitted: onSubmitted,
              textInputAction: onSubmitted == null ? null : TextInputAction.next,
              style: PmText.sans(14.5, color: pm.ink, ls: obscure ? 0.3 : 0),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: PmText.sans(14.5, color: pm.ink2, ls: obscure ? 0.3 : 0),
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
