import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:field_track/app/theme/app_colors.dart';
import 'package:field_track/app/theme/app_text_styles.dart';
import 'package:field_track/core/widgets/app_button.dart';
import 'package:field_track/core/widgets/app_text_field.dart';
import 'package:field_track/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:field_track/features/auth/presentation/bloc/auth_event.dart';
import 'package:field_track/features/auth/presentation/bloc/auth_state.dart';

/// Register screen — Figma Screen 02.
///
/// FieldTrack logo, "Create your account", full name + email + password fields,
/// "Create account" button, sign in link.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onCreateAccount() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters.';
      });
      return;
    }

    setState(() => _errorMessage = null);
    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            email: email,
            password: password,
            fullName: name,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/tasks');
        } else if (state is AuthError) {
          setState(() => _errorMessage = state.message);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 76),

                // ─── Logo ──────────────────────────────────────
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.pin_drop_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 22),

                // ─── Title ─────────────────────────────────────
                Text(
                  'Create your account',
                  style: AppTextStyles.heading2.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join your team on FieldTrack',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),

                const SizedBox(height: 32),

                // ─── Error message ─────────────────────────────
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.errorSurfaceDark
                          : AppColors.errorSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ─── Full name field ───────────────────────────
                AppTextField(
                  label: 'Full name',
                  hintText: 'John Doe',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 14),

                // ─── Email field ───────────────────────────────
                AppTextField(
                  label: 'Email',
                  hintText: 'john.doe@example.com',
                  controller: _emailController,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 14),

                // ─── Password field ────────────────────────────
                AppTextField(
                  label: 'Password',
                  hintText: 'Create a password',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  suffixWidget: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 19,
                      color: isDark ? AppColors.iconDark : AppColors.iconLight,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Create account button ─────────────────────
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AppButton.primary(
                      text: 'Create account',
                      isLoading: state is AuthLoading,
                      onPressed: _onCreateAccount,
                    );
                  },
                ),

                const SizedBox(height: 22),

                // ─── Sign in link ──────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Sign in',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
