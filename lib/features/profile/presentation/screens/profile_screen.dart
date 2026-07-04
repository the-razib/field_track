import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:field_track/app/theme/app_colors.dart';
import 'package:field_track/app/theme/app_text_styles.dart';
import 'package:field_track/core/widgets/app_button.dart';
import 'package:field_track/core/widgets/status_badge.dart';
import 'package:field_track/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:field_track/features/auth/presentation/bloc/auth_event.dart';
import 'package:field_track/features/auth/presentation/bloc/auth_state.dart';
import 'package:field_track/features/locations/presentation/bloc/location_bloc.dart';
import 'package:field_track/features/locations/presentation/bloc/location_state.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ───────────────────────────────────
              Text(
                'Profile',
                style: AppTextStyles.heading1.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 18),

              // ─── Profile Card ──────────────────────────────
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String name = 'John Doe';
                  String email = 'john.doe@example.com';
                  String initials = 'JD';
                  String role = 'Field User';

                  if (state is AuthAuthenticated && state.user != null) {
                    name = state.user!.displayName;
                    email = state.user!.email;
                    initials = state.user!.initials;
                    role = state.user!.role ?? 'Field User';
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            initials,
                            style: AppTextStyles.statNumber.copyWith(
                              color: AppColors.primary,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: AppTextStyles.heading3.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 14),
                        StatusBadge.neutral(text: role),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ─── Quick Stats Row ───────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Tasks done today',
                      builder: (context) {
                        final state = context.watch<TodoBloc>().state;
                        if (state is TodoLoaded) {
                          final total = state.todos.length;
                          final completed = state.todos.where((t) => t.isCompleted).length;
                          return '$completed/$total';
                        }
                        return '0/0';
                      },
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Active locations',
                      builder: (context) {
                        final state = context.watch<LocationBloc>().state;
                        if (state is LocationLoaded) {
                          final active = state.locations.where((l) => l.isActive).length;
                          return '$active';
                        }
                        return '0';
                      },
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ─── Account Menu ──────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(Icons.person_outline, 'Edit profile', isDark),
                    _buildDivider(isDark),
                    _buildMenuItem(Icons.notifications_none_outlined, 'Notifications', isDark),
                    _buildDivider(isDark),
                    _buildMenuItem(Icons.settings_outlined, 'Settings', isDark),
                    _buildDivider(isDark),
                    _buildMenuItem(Icons.help_outline_rounded, 'Help & support', isDark),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── Sign Out Button ───────────────────────────
              AppButton.destructive(
                text: 'Sign out',
                icon: Icons.logout_rounded,
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String Function(BuildContext) builder,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            builder(context),
            style: AppTextStyles.statNumber.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, bool isDark) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDarkElevated : AppColors.backgroundLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: isDark ? AppColors.iconDark : AppColors.iconLight),
      ),
      title: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 18,
        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
      ),
      onTap: () {},
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
    );
  }
}
