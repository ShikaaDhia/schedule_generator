import 'package:flutter/material.dart';
import 'package:schedule_generator/models/task.dart';

// IMPORTANT: untk mendefinisikan sebuah variable, yg bersifat public/private
// wajib untk dideskripsikan di dalam blok code.
// ini bersifat public
class TaskInputSection extends StatefulWidget {
  final void Function(Task) onTaskAdded;
  const TaskInputSection({super.key, required this.onTaskAdded});

  @override
  State<TaskInputSection> createState() => _TaskInputSectionState();
}

// ini bersifat private
class _TaskInputSectionState extends State<TaskInputSection> {
  final taskController = TextEditingController();
  final durationController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  void  _addTask() {
    // perkondisian apabila seluruh input area masih kosong
    if (taskController.text.isEmpty ||
      durationController.text.isEmpty ||
      selectedDate == null ||
      // kita ga ngeset sbgi mandatory, masih ngsih perkondisian or (apabila slh satu bernilai true)
      // untk ngasih tau, apapun hsilnya yg pnting ada salah satu yg true
      // keywrod return digunakan untk mengembalikan hasil
      selectedTime == null) return;

      final deadline = DateTime(
        // untk dituangkan ke container, dmna container trsbt tmpt task trsbt udh diinput user
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute
      );

      // ngehandle ktika task sudh diinput
      widget.onTaskAdded(Task(
        name: taskController.text,
        duration: int.tryParse(durationController.text) ?? 0,
        deadline: deadline
      ));

      // statement ini akan dijalankan ktika satu buah task lengkap sudh berhasil
      // dan dimasukkan ke dalam container list tasks
      taskController.clear();
      durationController.clear();
      setState(() {
        selectedDate = null;
        selectedTime = null;
      });
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030)
    );
    if (date != null) setState(() => selectedDate = date);
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now()
    );
    if (time != null) setState(() => selectedTime = time);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child:  Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: const InputDecoration(labelText: "Task Name")
            ),
            const SizedBox(height: 10),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Duration (minutes)"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDate,
                    child: Text( selectedDate == null
                      ? "Pick Date"
                      : "${selectedDate!.toLocal()}".split('') [0]
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickTime,
                    child: Text( selectedTime == null
                      ? "Pick Time"
                      : selectedTime!.format(context)
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text("Add Task"),
            )
          ],
        ),
      ),
    );
  }
}