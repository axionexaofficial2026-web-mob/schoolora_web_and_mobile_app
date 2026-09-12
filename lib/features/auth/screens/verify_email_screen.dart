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

class VerifyEmailScreen extends StatefulWidget {
  final String? initialToken;

  const VerifyEmailScreen({super.key, this.initialToken});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tokenController;
  final _resendEmailController = TextEditingController();

  bool _isVerified = false;
  bool _showResend = false;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.initialToken ?? '');
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _resendEmailController.dispose();
    super.dispose();
  }

  Future<void> _verifyToken() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyEmail(
      token: _tokenController.text.trim(),
    );

    if (success && mounted) {
      setState(() {
        _isVerified = true;
      });
    }
  }

  Future<void> _resendEmail() async {
    final email = _resendEmailController.text.trim();
    if (email.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.resendVerificationEmail(email: email);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return AuthScaffold(
      title: 'Email Verification',
      subtitle: _isVerified
          ? 'Your email address has been verified successfully'
          : 'Enter your verification token to confirm your email address',
      bottomAction: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Back to ',
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
      child: _isVerified
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
                      Icons.verified_outlined,
                      color: AppColors.success,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  authProvider.successMessage ??
                      'Email verified successfully! You can now sign in.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: 'Proceed to Sign In',
                  isFullWidth: true,
                  size: AppButtonSize.lg,
                  onPressed: () => context.go(RoutePaths.login),
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

                  if (authProvider.successMessage != null && !_isVerified) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF14532D)
                            : const Color(0xFFDCFCE7),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: Text(
                        authProvider.successMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFF14532D),
                        ),
                      ),
                    ),
                  ],

                  AppTextField(
                    controller: _tokenController,
                    label: 'Verification Token',
                    hintText: 'Paste token from verification email',
                    prefixIcon: const Icon(Icons.security_outlined, size: 20),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Verification token is required';
                      }
                      if (value.trim().length < 6) {
                        return 'Invalid verification token';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AppButton(
                    text: 'Verify Email',
                    isLoading: authProvider.isLoading,
                    isFullWidth: true,
                    size: AppButtonSize.lg,
                    onPressed: authProvider.isLoading ? null : _verifyToken,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showResend = !_showResend;
                        });
                      },
                      child: Text(
                        _showResend
                            ? 'Cancel Resend'
                            : 'Didn\'t receive an email? Resend verification',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.primaryDarkTheme
                              : AppColors.primaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  if (_showResend) ...[
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: _resendEmailController,
                      label: 'Email to Resend Link',
                      hintText: 'user@schoolora.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      text: 'Send New Verification Email',
                      variant: AppButtonVariant.outline,
                      isLoading: authProvider.isLoading,
                      isFullWidth: true,
                      onPressed: authProvider.isLoading ? null : _resendEmail,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
