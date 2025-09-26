import 'package:flutter/material.dart';
import 'toDoItemPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<TodoItem> _tasks = [];
  bool _loading = false;
  final String _table = 'tasks';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _loading = true);
    try {
      final response = await Supabase.instance.client
          .from(_table)
          .select()
          .order('created_at', ascending: false);
      final List data = response as List; // supabase returns List<dynamic>
      _tasks
        ..clear()
        ..addAll(data.map((e) => TodoItem.fromMap(e as Map<String, dynamic>)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load tasks: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addTask() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      try {
        final inserted = await Supabase.instance.client
            .from(_table)
            .insert({'text': text, 'is_done': false})
            .select()
            .single();
        setState(() {
          _tasks.insert(0, TodoItem.fromMap(inserted));
          _controller.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add task: $e')),
        );
      }
    }
  }

  Future<void> _deleteTask(int index) async {
    final task = _tasks[index];
    setState(() {
      _tasks.removeAt(index);
    });
    if (task.id.isEmpty) return;
    try {
      await Supabase.instance.client.from(_table).delete().eq('id', task.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
      // best-effort refetch
      _fetchTasks();
    }
  }

  Future<void> _toggleTask(int index) async {
    final task = _tasks[index];
    final newVal = !task.isDone;
    setState(() {
      _tasks[index].isDone = newVal;
    });
    if (task.id.isEmpty) return;
    try {
      await Supabase.instance.client
          .from(_table)
          .update({'is_done': newVal})
          .eq('id', task.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
      setState(() {
        _tasks[index].isDone = !newVal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todo App'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchTasks,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : (_tasks.isEmpty
                  ? _buildEmptyState(context)
                  : _buildTaskList(context)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tasks.isEmpty) {
            _showAddTaskDialog(context);
          } else {
            _addTask();
          }
        },
        label: Text(_tasks.isEmpty ? 'Add task' : 'Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'What do you want to do?',
                    prefixIcon: const Icon(Icons.edit_outlined),
                    suffixIcon: _controller.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear',
                            onPressed: () {
                              setState(() => _controller.clear());
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                  onSubmitted: (_) => _addTask(),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _addTask,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (_) => _toggleTask(index),
                    ),
                    title: Text(
                      task.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                      color: colorScheme.error,
                      onPressed: () => _deleteTask(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 120, color: colorScheme.primary.withOpacity(0.2)),
            const SizedBox(height: 24),
            Text(
              'No tasks yet',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first task',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String newTask = '';
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => newTask = value,
            decoration: const InputDecoration(hintText: 'Enter task'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (newTask.trim().isNotEmpty) {
                  setState(() {
                    _tasks.add(TodoItem(newTask.trim()));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
