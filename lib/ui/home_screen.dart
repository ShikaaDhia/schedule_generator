import 'package:flutter/material.dart';
import 'package:schedule_generator/models/task.dart';
import 'package:schedule_generator/services/gemini_service.dart';
import 'package:schedule_generator/ui/home_components/generate_button.dart';
import 'package:schedule_generator/ui/home_components/task_input.dart';
import 'package:schedule_generator/ui/home_components/task_list.dart';
import 'package:schedule_generator/ui/result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [];
  final GeminiService geminiService = GeminiService();
  bool isLoading = false;
  String? generatedResult;

  // code handling untk action penambahan/penginputan task
  void addTask(Task task) {
    setState(() => tasks.add(task));
  }

  // code handling untk action penghapusan task yg sudah diinput
  void removeTask(int index) {
    setState(() => tasks.removeAt(index));
  }

  // code handling untk melakukan generate schedule berdasarkan input user
  Future<void> generatedSchedule() async {
    setState(() => isLoading = true);
    try {
      final result = await geminiService.generateSchedule(tasks);
      generatedResult = result;
      if (context.mounted) _showSuccessDialog();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate: $e')),
        );
      }
    }
    setState(() => isLoading = false);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Congrats!"),
        content: const Text("Schedule generated successfully."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultScreen(result: generatedResult ?? "There is no result. Please try to generate another task",)
                )
              );
            },
            child: const Text("View Result"),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final sectionColor = Colors.grey[100];
    final sectionTitleStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Generator"),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sectionColor,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Task Input", style: sectionTitleStyle),
                  const SizedBox(height: 12),
                  TaskInputSection(onTaskAdded: addTask)
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sectionColor,
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Task List", style: sectionTitleStyle),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TaskList(tasks: tasks, onRemove: removeTask),
                    )
                  ]
                ),
              ),
            ),
            const SizedBox(height: 20),
            GenerateButton(
              isLoading: isLoading,
              onPressed: generatedSchedule,
            )
          ],
        ),
      ),
    );
  }
}