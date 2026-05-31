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

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
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
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        context.read<TaskBloc>().add(LoadTasks()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is TaskLoaded) {
            if (state.filteredTasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_outlined,
                      size: 80,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to create your first task',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TaskBloc>().add(LoadTasks());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.filteredTasks.length,
                onReorder: (oldIndex, newIndex) {
                  context.read<TaskBloc>().add(
                        ReorderTasks(oldIndex, newIndex),
                      );
                },
                itemBuilder: (context, index) {
                  final task = state.filteredTasks[index];
                  return TaskCard(
                    key: ValueKey(task.id),
                    task: task,
                    onTap: () => context.push('/task/${task.id}'),
                    onToggleStatus: () {
                      final newStatus = task.status == TaskStatus.completed
                          ? TaskStatus.pending
                          : TaskStatus.completed;
                      context.read<TaskBloc>().add(
                            UpdateTask(task.copyWith(status: newStatus)),
                          );
                    },
                    onDelete: () {
                      context.read<TaskBloc>().add(DeleteTask(task.id));
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: const AddTaskSheet(),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: true,
                      onSelected: (_) {
                        this.context.read<TaskBloc>().add(
                              const FilterTasksByStatus(null),
                            );
                        Navigator.pop(context);
                      },
                    ),
                    ...TaskStatus.values.map((status) {
                      return FilterChip(
                        label: Text(status.name),
                        selected: false,
                        onSelected: (_) {
                          this.context.read<TaskBloc>().add(
                                FilterTasksByStatus(status),
                              );
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
