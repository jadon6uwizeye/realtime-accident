import 'package:flutter/material.dart';
import 'package:realtime_accident/models/accident.dart';
import 'package:realtime_accident/models/user.dart';
import 'package:realtime_accident/services/db_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<List<Map<String, dynamic>>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = _loadDashboardData();
  }

  Future<List<Map<String, dynamic>>> _loadDashboardData() async {
    List<Accident> accidents = await DatabaseService.instance.getAccidents(null);
    List<Map<String, dynamic>> combinedData = [];

    for (var accident in accidents) {
      User? user = await DatabaseService.instance.getUserById(accident.userId);
      combinedData.add({
        'accident': accident,
        'user': user,
        'isExpanded': false, // Track expansion state
      });
    }

    return combinedData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page title with padding
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.blueGrey.shade50,
            child: const Text(
              "Accident Records",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.blueGrey),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _dashboardData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No accident records found",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                } else {
                  List<Map<String, dynamic>> data = snapshot.data!;
                  return ListView(
                    children: data.map((record) {
                      final accident = record['accident'] as Accident;
                      final user = record['user'] as User?;
                      bool isExpanded = record['isExpanded'];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: ExpansionPanelList(
                          elevation: 1,
                          expandedHeaderPadding: EdgeInsets.zero,
                          expansionCallback: (index, expanded) {
                            setState(() {
                              record['isExpanded'] = !isExpanded;
                            });
                          },
                          children: [
                            ExpansionPanel(
                              isExpanded: isExpanded,
                              backgroundColor: Colors.blueGrey.shade50,
                              headerBuilder: (context, isExpanded) {
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: const Icon(Icons.warning,
                                      color: Colors.red),
                                  title: Text(
                                    "Location: (${accident.latitude.toStringAsFixed(4)}, ${accident.longitude.toStringAsFixed(4)})",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Time: ${accident.timestamp}",
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                );
                              },
                              body: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: user != null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "User Information",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.person,
                                                  color: Colors.blue),
                                              const SizedBox(width: 8),
                                              Text("Name: ${user.name}"),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.email,
                                                  color: Colors.green),
                                              const SizedBox(width: 8),
                                              Text("Email: ${user.email}"),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.phone,
                                                  color: Colors.orange),
                                              const SizedBox(width: 8),
                                              Text(
                                                  "Phone: ${user.phoneNumber ?? 'N/A'}"),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.home,
                                                  color: Colors.purple),
                                              const SizedBox(width: 8),
                                              Text(
                                                  "Plate number: ${user.plateNumber ?? 'N/A'}"),
                                            ],
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        "No user information available.",
                                        style: TextStyle(color: Colors.red),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
