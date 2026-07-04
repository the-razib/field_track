import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_track/app/theme/app_colors.dart';
import 'package:field_track/app/theme/app_text_styles.dart';
import 'package:field_track/core/network/connectivity_service.dart';
import 'package:field_track/core/widgets/app_button.dart';
import 'package:field_track/core/widgets/status_badge.dart';
import 'package:field_track/app/di/injection_container.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_event.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_state.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  late final ConnectivityService _connectivityService;
  ConnectivityStatus _connectivityStatus = ConnectivityStatus.online;
  StreamSubscription? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivityService = sl<ConnectivityService>();
    _checkInitialConnectivity();
    _connectivitySubscription = _connectivityService.statusStream.listen((status) {
      setState(() => _connectivityStatus = status);
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final status = await _connectivityService.currentStatus;
    if (mounted) {
      setState(() => _connectivityStatus = status);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOffline = _connectivityStatus == ConnectivityStatus.offline;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Sync',
                    style: AppTextStyles.heading1.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Offline Banner ────────────────────────────
            if (isOffline)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.warningSurfaceDark : AppColors.warningSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.warningSurfaceDark : AppColors.warning,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: AppColors.warning, size: 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "You're offline",
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isDark ? Colors.white : AppColors.warningSurfaceDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Changes are saved on this device",
                              style: AppTextStyles.caption.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ─── Pending Items ─────────────────────────────
            Expanded(
              child: BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) {
                  if (state is TodoLoaded) {
                    final pending = state.todos.where((t) => t.isPendingSync).toList();

                    if (pending.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_done_outlined,
                                size: 54,
                                color: isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight),
                            const SizedBox(height: 12),
                            Text(
                              "All changes synced",
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: pending.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = pending[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      item.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: AppTextStyles.labelMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.isCompleted ? "Marked Completed" : "Marked Pending",
                                            style: AppTextStyles.caption.copyWith(
                                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const StatusBadge.pending(text: 'Waiting to sync'),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        // Sync Now button
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: AppButton.primary(
                            text: 'Sync now',
                            isLoading: state.isSyncing,
                            onPressed: isOffline
                                ? null
                                : () {
                                    context.read<TodoBloc>().add(const TodosSyncRequested());
                                  },
                        ),
                        ),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
