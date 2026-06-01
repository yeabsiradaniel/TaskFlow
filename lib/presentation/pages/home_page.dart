import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/task_entity.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          // Build stats for header
          int total = 0;
          int completed = 0;
          if (state is TaskLoaded) {
            total = state.tasks.length;
            completed = state.tasks.where((t) => t.status == TaskStatus.completed).length;
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text(
                  'TaskFlow',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.label_outline),
                    onPressed: () => context.push('/categories'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterSheet,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
              if (state is TaskLoaded && state.tasks.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: _buildProgressCard(theme, total, completed),
                  ),
                ),
              if (state is TaskLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (state is TaskError)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48,
                            color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () =>
                              context.read<TaskBloc>().add(LoadTasks()),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              if (state is TaskLoaded && state.filteredTasks.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.task_outlined,
                            size: 64,
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No tasks yet',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to get started',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (state is TaskLoaded && state.filteredTasks.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = state.filteredTasks[index];
                        return TaskCard(
                          key: ValueKey(task.id),
                          task: task,
                          onTap: () => context.push('/task/${task.id}'),
                          onToggleStatus: () {
                            final newStatus =
                                task.status == TaskStatus.completed
                                    ? TaskStatus.pending
                                    : TaskStatus.completed;
                            context.read<TaskBloc>().add(
                                  UpdateTask(
                                      task.copyWith(status: newStatus)),
                                );
                          },
                          onDelete: () {
                            context
                                .read<TaskBloc>()
                                .add(DeleteTask(task.id));
                          },
                        );
                      },
                      childCount: state.filteredTasks.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTaskSheet(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Task'),
        ),
      ),
    );
  }

  Widget _buildProgressCard(ThemeData theme, int total, int completed) {
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                '$completed / $total',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor:
                      theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(
                    theme.colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            total == 0
                ? 'Add your first task!'
                : completed == total
                    ? 'All done! Great work.'
                    : '${total - completed} task${total - completed == 1 ? '' : 's'} remaining',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: const AddTaskSheet(),
      ),
    );
  }

  void _showFilterSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Filter Tasks',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: true,
                      onSelected: (_) {
                        context.read<TaskBloc>().add(
                              const FilterTasksByStatus(null),
                            );
                        Navigator.pop(sheetContext);
                      },
                    ),
                    ...TaskStatus.values.map((status) {
                      return FilterChip(
                        label: Text(status.name[0].toUpperCase() +
                            status.name.substring(1)),
                        selected: false,
                        onSelected: (_) {
                          context.read<TaskBloc>().add(
                                FilterTasksByStatus(status),
                              );
                          Navigator.pop(sheetContext);
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
