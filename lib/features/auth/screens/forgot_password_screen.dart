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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(
      email: _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() {
        _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return AuthScaffold(
      title: 'Reset Password',
      subtitle: _submitted
          ? 'Check your inbox for password reset instructions'
          : 'Enter your registered email to receive a password reset link',
      bottomAction: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Remember your password? ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          InkWell(
            onTap: () => context.go(RoutePaths.login),
            child: Text(
              'Sign In',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.primaryDarkTheme
                    : AppColors.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      child: _submitted
          ? Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF14532D)
                        : const Color(0xFFDCFCE7),
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mark_email_read_outlined,
                      color: AppColors.success,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  authProvider.successMessage ??
                      'If an account exists with this email, a password reset link has been dispatched.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: 'Enter Reset Code',
                  isFullWidth: true,
                  size: AppButtonSize.lg,
                  onPressed: () => context.push(RoutePaths.resetPassword),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  text: 'Resend Email',
                  variant: AppButtonVariant.outline,
                  isFullWidth: true,
                  onPressed: () {
                    setState(() {
                      _submitted = false;
                    });
                  },
                ),
              ],
            )
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                    controller: _emailController,
                    label: 'Email Address',
                    hintText: 'user@schoolora.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email address';
                      }
                      final emailRegExp = RegExp(
                        r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$',
                      );
                      if (!emailRegExp.hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AppButton(
                    text: 'Send Reset Link',
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
