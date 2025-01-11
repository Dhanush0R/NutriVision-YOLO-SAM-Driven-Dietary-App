import 'package:flutter/material.dart';

const List<Map<String, Object>> _usertiles = [
  {"value": "User Info", "icon": Icons.person_rounded},
  {"value": "Daily Intake", "icon": Icons.bar_chart_rounded},
  {"value": "LogOut", "icon": Icons.logout_outlined}
];

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/avatar2.png",
              width: 200,
              fit: BoxFit.cover,
              height: 200,
            ),
            const Text(
              "Akshay Rajput",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const Text("@rajputakshay",
                style: TextStyle(
                  fontSize: 18,
                )),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        titleTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        onTap: () {},
                        leading: Container(
                            width: 50,
                            height: 50,
                            decoration: const ShapeDecoration(
                                color: Color.fromARGB(40, 255, 147, 134),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            child: Icon(
                              _usertiles[index]["icon"] as IconData,
                              color: const Color.fromARGB(255, 255, 147, 134),
                              size: 35,
                            )),
                        title: Text(
                          _usertiles[index]["value"] as String,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
