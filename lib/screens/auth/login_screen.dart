import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/accessibility/a11y.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cinController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _cinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(currentUserProvider.notifier).login(
            _nameController.text.trim(),
            _cinController.text.trim(),
          );
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _enterAsVisitor() {
    ref.read(currentUserProvider.notifier).loginAsVisitor();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Semantics(
                    label: 'Running Club Tunis logo',
                    child: Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_run,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  // Title
                  Text(
                    tr('login'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('login_subtitle'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Error
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Name field
                  A11y.label(
                    label: tr('name'),
                    child: TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: tr('name'),
                        prefixIcon: const Icon(Icons.person_outline),
                        hintText: tr('name_hint'),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return tr('name_required');
                        }
                        if (val.trim().length < 2) {
                          return tr('name_too_short');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CIN Password field (3 digits)
                  A11y.label(
                    label: tr('password'),
                    child: TextFormField(
                      controller: _cinController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 3,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: InputDecoration(
                        labelText: tr('password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        hintText: tr('password_hint'),
                        counterText: '',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return tr('password_required');
                        }
                        if (val.trim().length != 3) {
                          return tr('password_length');
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _login(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  A11y.touchTarget(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(tr('login')),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          tr('or'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Visitor button
                  A11y.touchTarget(
                    child: OutlinedButton.icon(
                      onPressed: _enterAsVisitor,
                      icon: const Icon(Icons.visibility_outlined),
                      label: Text(tr('continue_as_visitor')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
