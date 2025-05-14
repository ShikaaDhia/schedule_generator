/*
file yg berada di dlm folder model..
biasa disebut dengan Data Class

biasanya, data class dipresentasikan dengan bundling..
dengan meng-import library Parcelize = Android Native
*/

class Task {
  final String name;
  final int duration;
  final DateTime deadline;

  Task({required this.name, required this.duration, required this.deadline});

  //untk membuat suatu turuna dri object
  // salah satu contohnya adalah...
  // adanya function di dalam function
  @override
  String toString() {
    return "Task{name: $name, duration: $duration, deadline: $deadline}";
  }
  
}