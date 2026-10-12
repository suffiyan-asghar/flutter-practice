class Job {
  final String title;
  final String companyname;
  final String logoUrl;
  final String location;
  final String jobType;
  final String workplace;
  final String createdDate;

  Job({
    required this.title,
    required this.companyname,
    required this.logoUrl,
    required this.location,
    required this.jobType,
    required this.workplace,
    required this.createdDate,

  });


  factory Job.fromJson(Map<String,dynamic> json){
    final job = json['job'];

    return Job(
      title: job['title'],
      companyname: job['company']['name'],
      logoUrl: job['company']['logo'],
      location: job['location']['name_en'],
      jobType: job['type']['name_en'],
      workplace: job['workplace_type']['name_en'],
      createdDate: job['created_date'],

    );
  }
}


// // Pass in ONE item of the "data" list, i.e. {"job": {...}} factory Job.fromJson(Map<String, dynamic> json) { final job = json['job'];

// what if i had to pass multiple items?

// final decoded = jsonDecode(response.body);        // the whole response (a Map)
// final List items = decoded['data'];               // the list of {"job": {...}}

// List<Job> jobs = items
//     .map((item) => Job.fromJson(item))
//     .toList();