import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiCall extends StatefulWidget {
  const ApiCall({super.key});

  @override
  State<ApiCall> createState() => _ApiCallState();
}

class _ApiCallState extends State<ApiCall> {
  final String url = "https://reqres.in/api/users?page=2";
  Map<String, dynamic> data = {};
  List<dynamic> filteredData = [];
  final TextEditingController textController = TextEditingController();

  void getDataFromApi(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          data = decoded;
          filteredData = decoded["data"];
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void filterUser(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredData = data["data"];
      });
    } else {
      final List<dynamic> allUsers = data["data"];
      final List<dynamic> results =
          allUsers.where((user) {
            final fullName =
                '${user["first_name"]} ${user["last_name"]}'.toLowerCase();
            return fullName.contains(query.toLowerCase());
          }).toList();

      setState(() {
        filteredData = results;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getDataFromApi(context);
    textController.addListener(() {
      filterUser(textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          "Api Call",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _textField(controller: textController),
            ),
            SizedBox(
              height: size.height * 0.8,
              width: size.width,
              child:
                  filteredData.isEmpty
                      ? const Center(child: Text("No users found"))
                      : ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final user = filteredData[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user["avatar"]),
                              radius: 30,
                            ),
                            title: Row(
                              children: [
                                Text(user["first_name"]),
                                const SizedBox(width: 5),
                                Text(user["last_name"]),
                              ],
                            ),
                            subtitle: Text(user["email"]),
                            trailing: Text(user["id"].toString()),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
        suffixIcon:
            controller.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    filterUser(""); // Reset to all users
                  },
                )
                : null,
        hintText: "Search",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
