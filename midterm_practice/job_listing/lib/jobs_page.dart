import 'package:flutter/material.dart';
import 'package:midterm_practice/model/job.dart';
import 'package:midterm_practice/service/job_service.dart';
import 'job_card.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  late Future<List<Job>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = fetchJobs(); // called once, not on every rebuild
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Job>>(
      future: _jobsFuture,
      builder: (context, snapshot) {
        // 1. Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Something went wrong'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _jobsFuture = fetchJobs(); // retry
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // 3. Data
        final jobs = snapshot.data!;
        if (jobs.isEmpty) {
          return const Center(child: Text('No jobs found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          itemBuilder: (context, index) => JobCard(job: jobs[index]),
        );
      },
    );
  }
}

// 1. Why it's a StatefulWidget
// dart
// class JobsPage extends StatefulWidget { ... }
// class _JobsPageState extends State<JobsPage> { ... }

// The page needs to remember something between rebuilds: the in-progress request for jobs. A stateless widget can't hold onto that, so we use a stateful one.

// 2. Storing the Future
// dart
// late Future<List<Job>> _jobsFuture;

// @override
// void initState() {
//   super.initState();
//   _jobsFuture = fetchJobs();
// }
// fetchJobs() starts the network request and immediately returns a Future, a promise that a list of jobs will arrive later.
// We save that Future in _jobsFuture.
// late means "I'll assign this before I use it, just not at declaration." We assign it in initState.
// initState runs once, when the widget is first created. This matters because build() can run many times (rotation, setState, parent rebuilds). If we called fetchJobs() inside build, we'd hit the API again on every rebuild.
// 3. FutureBuilder
// dart
// return FutureBuilder<List<Job>>(
//   future: _jobsFuture,
//   builder: (context, snapshot) { ... },
// );

// FutureBuilder watches a Future and rebuilds its UI whenever the Future's status changes. Its builder function receives a snapshot, which describes the current status:

// Property	Meaning
// snapshot.connectionState	Is it still waiting or done?
// snapshot.hasError	Did the Future throw an exception?
// snapshot.data	The result (the List<Job>) once it's ready
// 4. The three states inside builder

// The builder runs several times over the life of the request, and each time it returns a different widget.

// Loading

// dart
// if (snapshot.connectionState == ConnectionState.waiting) {
//   return const Center(child: CircularProgressIndicator());
// }

// The request is in flight, so show a spinner.

// Error

// dart
// if (snapshot.hasError) { ... Retry button ... }

// Remember that fetchJobs throws an exception on a non-200 status. That's what sets hasError to true. The Retry button does:

// dart
// setState(() { _jobsFuture = fetchJobs(); });

// This creates a new Future, and setState triggers a rebuild so FutureBuilder starts watching the new one, which shows the spinner again.

// Data

// dart
// final jobs = snapshot.data!;

// The ! says "I'm sure this isn't null here." That's safe because we've already ruled out loading and error. Then:

// dart
// return ListView.builder(
//   padding: const EdgeInsets.all(16),
//   itemCount: jobs.length,
//   itemBuilder: (context, index) => JobCard(job: jobs[index]),
// );
// itemCount tells the list how many items exist.
// itemBuilder is called with each index and returns the widget for that row. Here it passes jobs[index] into a JobCard.
// It builds rows lazily, only as they scroll into view.