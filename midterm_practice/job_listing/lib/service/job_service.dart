import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:midterm_practice/model/job.dart';

Future<List<Job>> fetchJobs() async{
  final url = Uri.parse('https://mpa0771a40ef48fcdfb7.free.beeceptor.com/jobs');
  final response = await http.get(url);
  if (response.statusCode ==200){
    final decoded = jsonDecode(response.body);
    final List items = decoded['data'];
    return items.map((item) =>Job.fromJson(item)).toList();
  }
  else{
    throw Exception('Failed to load jobs (status ${response.statusCode})');
  }

}

// Future<List<Job>> means "I'll hand you a list of jobs later," because the network call takes time.
// async lets you use await, which pauses this function until the response arrives without freezing the UI.
// Uri.parse(...) is needed because http.get takes a Uri, not a plain String.
// jsonDecode turns the JSON text into Dart maps and lists.
// Throwing an exception on a non-200 status is what lets FutureBuilder (Step 5) detect an error and show a message.

