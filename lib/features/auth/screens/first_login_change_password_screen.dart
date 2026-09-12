import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';

class FirstLoginChangePasswordScreen extends StatefulWidget {
  const FirstLoginChangePasswordScreen({super.key});

  @override
  State<FirstLoginChangePasswordScreen> createState() =>
      _FirstLoginChangePasswordScreenState();
}

class _FirstLoginChangePasswordScreenState
    extends State<FirstLoginChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=[\]{};\x27:"\\|,.<>/?]).{8,}$',
    );
    if (!regex.hasMatch(value)) {
      return 'Must include uppercase, lowercase, number, and special character';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.firstLoginChangePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (success && mounted) {
      context.go(RoutePaths.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return AuthScaffold(
      title: 'Action Required: Update Password',
      subtitle:
          'For security reasons, your initial or temporary password must be changed before accessing Schoolora ERP.',
      bottomAction: AppButton(
        text: 'Sign Out',
        variant: AppButtonVariant.ghost,
        size: AppButtonSize.sm,
        onPressed: () async {
          await authProvider.logout();
          if (context.mounted) {
            context.go(RoutePaths.login);
          }
        },
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Notice Banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E3A8A)
                    : const Color(0xFFDBEAFE),
                borderRadius: AppRadius.borderMd,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFBFDBFE),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.security_rounded,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'An administrator has required this account to establish a private, permanent password before continuing.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? const Color(0xFFDBEAFE)
                            : const Color(0xFF1E40AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (authProvider.isError && authProvider.error != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF7F1D1D)
                      : const Color(0xFFFEE2E2),
                  borderRadius: AppRadius.borderMd,
                ),
                child: Text(
                  authProvider.error!.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFF991B1B),
                  ),
                ),
              ),
            ],

            AppTextField(
              controller: _currentPasswordController,
              label: 'Temporary / Current Password',
              hintText: 'Enter temporary password',
              obscureText: _obscureCurrent,
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureCurrent
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () => setState(() {
                  _obscureCurrent = !_obscureCurrent;
                }),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Temporary password is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            AppTextField(
              controller: _newPasswordController,
              label: 'New Password',
              hintText: 'Min 8 chars, uppercase, lowercase, number, symbol',
              obscureText: _obscureNew,
              prefixIcon: const Icon(Icons.key_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () => setState(() {
                  _obscureNew = !_obscureNew;
                }),
              ),
              validator: _validateNewPassword,
            ),
            const SizedBox(height: AppSpacing.md),

            AppTextField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              hintText: 'Re-enter your new password',
              obscureText: _obscureConfirm,
              prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () => setState(() {
                  _obscureConfirm = !_obscureConfirm;
                }),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            AppButton(
              text: 'Save & Continue to Schoolora',
              isLoading: authProvider.isLoading,
              isFullWidth: true,
              size: AppButtonSize.lg,
              onPressed: authProvider.isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
