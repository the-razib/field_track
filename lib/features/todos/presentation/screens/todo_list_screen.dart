import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:field_track/app/theme/app_colors.dart';
import 'package:field_track/app/theme/app_text_styles.dart';
import 'package:field_track/core/widgets/status_badge.dart';
import 'package:field_track/features/todos/domain/entities/todo.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_event.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_state.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  int _activeTab = 0; // 0 = All, 1 = Pending, 2 = Completed

  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(const TodosLoadRequested());
  }

  List<Todo> _filterTodos(List<Todo> todos) {
    if (_activeTab == 1) {
      return todos.where((t) => !t.isCompleted).toList();
    } else if (_activeTab == 2) {
      return todos.where((t) => t.isCompleted).toList();
    }
    return todos;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentDateStr = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My tasks',
                          style: AppTextStyles.heading1.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentDateStr,
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BlocBuilder<TodoBloc, TodoState>(
                    builder: (context, state) {
                      final isSyncing = state is TodoLoaded && state.isSyncing;
                      if (isSyncing) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          child: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }
                      return IconButton(
                        icon: const Icon(Icons.sync, size: 20),
                        color: isDark ? AppColors.iconDark : AppColors.iconLight,
                        onPressed: () {
                          context.read<TodoBloc>().add(const TodosSyncRequested());
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Progress Card ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) {
                  int total = 0;
                  int completed = 0;
                  double percent = 0.0;

                  if (state is TodoLoaded) {
                    total = state.todos.length;
                    completed = state.todos.where((t) => t.isCompleted).toList().length;
                    percent = total > 0 ? completed / total : 0.0;
                  }

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's progress",
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              "$completed of $total done",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 8,
                            backgroundColor: isDark ? AppColors.borderDark : AppColors.dividerLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ─── Filter Tabs ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTabButton(0, 'All', isDark),
                  const SizedBox(width: 8),
                  _buildTabButton(1, 'Pending', isDark),
                  const SizedBox(width: 8),
                  _buildTabButton(2, 'Completed', isDark),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ─── Todos List ────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context.read<TodoBloc>().add(const TodosLoadRequested());
                },
                child: BlocBuilder<TodoBloc, TodoState>(
                  builder: (context, state) {
                    if (state is TodoLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state is TodoError) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 48,
                                    color: isDark
                                        ? AppColors.textTertiaryDark
                                        : AppColors.textTertiaryLight),
                                const SizedBox(height: 12),
                                Text(state.message, style: AppTextStyles.bodyMedium),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () => context
                                      .read<TodoBloc>()
                                      .add(const TodosLoadRequested()),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    if (state is TodoLoaded) {
                      final filtered = _filterTodos(state.todos);
                      if (filtered.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      size: 48,
                                      color: isDark
                                          ? AppColors.textTertiaryDark
                                          : AppColors.textTertiaryLight),
                                  const SizedBox(height: 12),
                                  Text(
                                    _activeTab == 2
                                        ? 'No completed tasks yet'
                                        : 'No tasks to do!',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _buildTodoCard(filtered[index], isDark),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, bool isDark) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary : AppColors.primarySurface)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected
                ? (isDark ? Colors.white : AppColors.primary)
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTodoCard(Todo todo, bool isDark) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox Custom Styling
          GestureDetector(
            onTap: () {
              context.read<TodoBloc>().add(TodoToggleRequested(
                    id: todo.id,
                    isCompleted: !todo.isCompleted,
                  ));
            },
            child: Container(
              margin: const EdgeInsets.only(top: 2),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: todo.isCompleted ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: todo.isCompleted ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 1.5,
                ),
              ),
              child: todo.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (todo.description != null && todo.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    todo.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (todo.dueTime != null) ...[
                      Icon(Icons.access_time, size: 13,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                      const SizedBox(width: 6),
                      Text(
                        todo.isCompleted
                            ? 'Done ${todo.dueTime}'
                            : 'Due ${todo.dueTime}',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    todo.isCompleted
                        ? const StatusBadge.completed(text: 'Completed')
                        : const StatusBadge.pending(text: 'Pending'),
                    
                    if (todo.isPendingSync) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.cloud_off, size: 14,
                          color: isDark ? AppColors.warning : AppColors.warning),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
