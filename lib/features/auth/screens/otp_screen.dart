import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/auth_models.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _identifierController = TextEditingController();
  final _otpController = TextEditingController();

  OtpPurpose _selectedPurpose = OtpPurpose.login;
  bool _otpSent = false;
  bool _isVerified = false;

  int _countdownSeconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _identifierController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    setState(() {
      _countdownSeconds = seconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds <= 1) {
        timer.cancel();
        setState(() {
          _countdownSeconds = 0;
        });
      } else {
        setState(() {
          _countdownSeconds--;
        });
      }
    });
  }

  Future<void> _requestOtp() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.requestOtp(
      identifier: identifier,
      purpose: _selectedPurpose,
    );

    if (result != null && mounted) {
      setState(() {
        _otpSent = true;
      });
      _startCountdown(
        result.expiresInSeconds > 0 ? result.expiresInSeconds : 60,
      );
    }
  }

  Future<void> _verifyOtp() async {
    final identifier = _identifierController.text.trim();
    final code = _otpController.text.trim();
    if (identifier.isEmpty || code.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(
      identifier: identifier,
      purpose: _selectedPurpose,
      code: code,
    );

    if (success && mounted) {
      setState(() {
        _isVerified = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return AuthScaffold(
      title: 'One-Time Password (OTP)',
      subtitle: _isVerified
          ? 'OTP code verified successfully'
          : _otpSent
          ? 'Enter the verification code dispatched to your identifier'
          : 'Request a secure single-use verification code',
      bottomAction: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Return to ',
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
                      Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  authProvider.successMessage ?? 'OTP verified successfully!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: 'Back to Sign In',
                  isFullWidth: true,
                  size: AppButtonSize.lg,
                  onPressed: () => context.go(RoutePaths.login),
                ),
              ],
            )
          : Column(
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

                // Purpose Dropdown
                DropdownButtonFormField<OtpPurpose>(
                  initialValue: _selectedPurpose,
                  decoration: const InputDecoration(
                    labelText: 'Verification Purpose',
                    prefixIcon: Icon(Icons.category_outlined, size: 20),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: OtpPurpose.login,
                      child: Text('Login Authentication'),
                    ),
                    DropdownMenuItem(
                      value: OtpPurpose.passwordReset,
                      child: Text('Password Reset'),
                    ),
                    DropdownMenuItem(
                      value: OtpPurpose.emailVerification,
                      child: Text('Email Verification'),
                    ),
                    DropdownMenuItem(
                      value: OtpPurpose.transactionVerification,
                      child: Text('Transaction Verification'),
                    ),
                  ],
                  onChanged: _otpSent
                      ? null
                      : (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPurpose = val;
                            });
                          }
                        },
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: _identifierController,
                  label: 'Email or Phone Identifier',
                  hintText: 'user@schoolora.com or +1234567890',
                  prefixIcon: const Icon(
                    Icons.account_circle_outlined,
                    size: 20,
                  ),
                  readOnly: _otpSent,
                ),
                const SizedBox(height: AppSpacing.md),

                if (!_otpSent) ...[
                  AppButton(
                    text: 'Send Verification Code',
                    isLoading: authProvider.isLoading,
                    isFullWidth: true,
                    size: AppButtonSize.lg,
                    onPressed: authProvider.isLoading ? null : _requestOtp,
                  ),
                ] else ...[
                  AppTextField(
                    controller: _otpController,
                    label: 'Enter OTP Code',
                    hintText: '6-digit code',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.dialpad_rounded, size: 20),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _countdownSeconds > 0
                            ? 'Expires in ${_countdownSeconds}s'
                            : 'Code expired',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _countdownSeconds > 0
                              ? (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight)
                              : AppColors.error,
                        ),
                      ),
                      TextButton(
                        onPressed:
                            (_countdownSeconds == 0 && !authProvider.isLoading)
                            ? _requestOtp
                            : null,
                        child: const Text('Resend Code'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AppButton(
                    text: 'Verify Code',
                    isLoading: authProvider.isLoading,
                    isFullWidth: true,
                    size: AppButtonSize.lg,
                    onPressed: authProvider.isLoading ? null : _verifyOtp,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  AppButton(
                    text: 'Change Identifier',
                    variant: AppButtonVariant.ghost,
                    isFullWidth: true,
                    onPressed: () {
                      setState(() {
                        _otpSent = false;
                        _otpController.clear();
                      });
                    },
                  ),
                ],
              ],
            ),
    );
  }
}
