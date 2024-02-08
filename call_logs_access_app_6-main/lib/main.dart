// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(CallLogApp());
}

class CallLogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call Log App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Call Log Access',
              style: TextStyle(
                  color: Color.fromARGB(255, 255, 252, 252),
                  fontWeight: FontWeight.bold,
                  fontSize: 21)),
          backgroundColor: Color.fromARGB(255, 29, 164, 14),
        ),
        body: FutureBuilder<Iterable<CallLogEntry>>(
          future: CallLog.get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: Unable to retrieve call log.'));
            } else if (snapshot.data!.isEmpty) {
              return Center(child: Text('No call log entries available.'));
            } else {
              List<CallLogEntry> sortedEntries = snapshot.data!.toList()
                ..sort((a, b) => b.timestamp!.compareTo(a.timestamp!));

              return ListView.builder(
                itemCount: sortedEntries.length,
                itemBuilder: (context, index) {
                  CallLogEntry entry = sortedEntries[index];

                  DateTime? timestamp = entry.timestamp != null
                      ? DateTime.fromMillisecondsSinceEpoch(entry.timestamp!)
                      : null;

                  String formattedDateTime = timestamp != null
                      ? DateFormat.yMMMMd().add_jms().format(timestamp)
                      : 'N/A';

                  return ListTile(
                    leading: Icon(entry.callType == CallType.incoming ? Icons.call_received : Icons.call_made),
                    title: Text('${entry.name ?? 'Unknown'}: ${entry.number}'),
                    subtitle: Text('$formattedDateTime | ${entry.duration} seconds'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CallDetailsScreen(entry)),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class CallDetailsScreen extends StatelessWidget {
  final CallLogEntry entry;

  CallDetailsScreen(this.entry);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${entry.name ?? 'Unknown'}'),
            Text('Number: ${entry.number}'),
            Text('Type: ${entry.callType.toString().split('.').last}'),
            Text('Duration: ${entry.duration} seconds'),
            Text('Date and Time: ${DateFormat.yMMMMd().add_jms().format(DateTime.fromMillisecondsSinceEpoch(entry.timestamp!))}'),
          ],
        ),
      ),
    );
  }
}
