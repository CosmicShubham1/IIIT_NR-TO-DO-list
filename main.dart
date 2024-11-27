import 'package:flutter/material.dart';

void main() => runApp(ToDoApp());

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IIIT-NR To-Do List',  // Updated app title
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: ToDoHome(),
    );
  }
}

class ToDoHome extends StatefulWidget {
  @override
  _ToDoHomeState createState() => _ToDoHomeState();
}

class _ToDoHomeState extends State<ToDoHome> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final List<int> _monthlyProgress = List.filled(30, 0); // Tracks 30 days.

  void _addTask(String task, String priority, String deadline) {
    if (task.isNotEmpty) {
      setState(() {
        _tasks.add({
          'title': task,
          'priority': priority,
          'deadline': deadline,
          'completed': false,
        });
        _updateMonthlyProgress();
      });
      _controller.clear();
      _priorityController.clear();
      _deadlineController.clear();
    }
  }

  void _removeTask(int index) {
    final removedTask = _tasks[index];
    setState(() {
      _tasks.removeAt(index);
      _updateMonthlyProgress();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${removedTask['title']}" removed.'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _tasks.insert(index, removedTask);
              _updateMonthlyProgress();
            });
          },
        ),
      ),
    );
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
      _updateMonthlyProgress();
    });
  }

  void _updateMonthlyProgress() {
    if (_tasks.isEmpty) {
      _monthlyProgress[DateTime.now().day - 1] = 0;
    } else {
      final completedTasks =
          _tasks.where((task) => task['completed']).length;
      final progress = ((completedTasks / _tasks.length) * 100).toInt();
      _monthlyProgress[DateTime.now().day - 1] = progress;
    }
  }

  double _getDailyProgress() {
    if (_tasks.isEmpty) return 0;
    final completedTasks =
        _tasks.where((task) => task['completed']).length;
    return completedTasks / _tasks.length;
  }

  int _calculateMonthlyAverage() {
    return _monthlyProgress.reduce((a, b) => a + b) ~/ _monthlyProgress.length;
  }

  @override
  Widget build(BuildContext context) {
    final int monthlyAverage = _calculateMonthlyAverage();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IIIT-NR To-Do List',  // Updated title in AppBar
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add a new task',
                hintText: 'Enter task here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add, color: Colors.teal),
                  onPressed: () => _addTask(
                    _controller.text,
                    _priorityController.text,
                    _deadlineController.text,
                  ),
                ),
              ),
              onSubmitted: (task) => _addTask(
                task,
                _priorityController.text,
                _deadlineController.text,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _priorityController,
              decoration: InputDecoration(
                labelText: 'Priority (High/Medium/Low)',
                hintText: 'Enter priority',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _deadlineController,
              decoration: InputDecoration(
                labelText: 'Deadline (yyyy-mm-dd)',
                hintText: 'Enter deadline',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LinearProgressIndicator(
              value: _getDailyProgress(),
              backgroundColor: Colors.grey[300],
              color: Colors.teal,
              minHeight: 8,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Today\'s Progress: ${(_getDailyProgress() * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: monthlyAverage / 100,
                  backgroundColor: Colors.grey[300],
                  color: Colors.teal,
                  minHeight: 8,
                ),
                SizedBox(height: 8),
                Text(
                  'Average Monthly Progress: $monthlyAverage%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? Center(
                    child: Text(
                      'No tasks added yet!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Card(
                        elevation: 2,
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: task['completed'],
                            onChanged: (_) => _toggleTask(index),
                          ),
                          title: Text(
                            task['title'],
                            style: TextStyle(
                              decoration: task['completed']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Priority: ${task['priority']} | Deadline: ${task['deadline']}',
                            style: TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeTask(index),
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
}
