import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:schedule_generator/models/task.dart';

class GeminiService {
  // untk gerbang komunikasi awal antara client dan server
  // client --> kode project/aplikasi yg telah di deploy
  // server --> Gemini API
  static const String _baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  final String apiKey;
  
  /*
  ini adalah sebuah ternary operator untuk memastikan..
  apakah nilai dari API KEY tersedia atau kosong
  */ 
  GeminiService() : apiKey = dotenv.env["GEMINI_API_KEY"] ?? "" {
    if (apiKey.isEmpty) {
      throw ArgumentError("Please input your API KEY");
    }
  }

  // logika untk generating result dari input/prompt yg diberikan
  // yang akan diotomasi oleh AI API
  Future<String> generateSchedule(List<Task> tasks) async {
    _validateTasks(tasks);
    // variable yg digunakan untk menampung prompt request yg akan dieksekusi oleh AI
    final prompt = _buildPrompt(tasks);

    // sebagai percobaan pengiriman request ke AI
    try {
      print("Prompt: \n$prompt");

      // variable yg digunakan untuk menampung hasil respon dari request ke API AI
      final response = await http.post(
        // ini adlh starting point untk penggunaan endpoint dri API
        // syntax yg digunakan oleh flutter untk awal mula menggunakan API
        Uri.parse("$_baseUrl?key=$apiKey"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              // role disini maksdnya adalah seorang yg memberikan instruksi kepada AI melalui prompt
              "role": "user",
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        })
      );

        return _handleResponse(response);
    } catch (e) {
      throw ArgumentError("Failed to generate schedule: $e");
    }
  }

  String _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    /* Switch adlh salah satu cabang dari perkondisian yg berisi statement general
    yg dpt di eksekusi oleh berbagai macam action (case), tanpa harus bergantung
    pada single-statement yg dimiliki oleh stiap action yg ada pada
    parameter "case".
    */
    // yg response.statusCode itu status general, bisa di eksekusi oleh semua action
    switch (response.statusCode) {
      case 200:
        return data["candidates"][0]["content"]["parts"][0]["text"];
        // WAJIB ada klo mau manggil data API
      case 404:
        throw ArgumentError("Server Note Found");
      case 500:
        throw ArgumentError("Internal Server Error");
      default:
        throw ArgumentError("Unknown Error: ${response.statusCode}");
    }
  }

  String _buildPrompt(List<Task> tasks) {
    // berfungsi untk menyetting format tanggal & waktu lokal(indonesia)
    initializeDateFormatting();
    final dateFormatter = DateFormat("dd mm yyyy 'pukul' hh:mm, 'id_ID'");
    final taskList = tasks.map((task) {
      final formatDeadline =dateFormatter.format(task.deadline);
      return "- ${task.name} (Duration: ${task.duration} minutes, Deadline: $formatDeadline)";
    });

  /* menggunakan framework R-T-A (Roles-Task-Action)
  untuk prompting*/
  return '''

 Saya adalah seorang siswa, dan saya memiliki daftar sebagai berikut:

 $taskList

 Tolong  susun jadwal yang optimal dan efisien berdasarkan daftar tugas tersebut.
 Tolong tentukan prioritasnya beradasrakan *deadline yang paling dekat* dan *durasi tugas*.
 Tolong buat jadwal yang sistematis dari pagi hari, sampai malam hari.
 Tolong pastikan semua tugas dapat selesai sebelum deadline.

 Tolong buatin output jadwal dalam format list per jam, misalnya:
 -07:00 - 08:00: Melaksanakan piket kamar

''';
  }

  void _validateTasks(List<Task> tasks) {
    // ini merupakan bntuk dri single statement dari if-else condition
    if (tasks.isEmpty) throw ArgumentError("Please input your tasks before generating");
  }

}