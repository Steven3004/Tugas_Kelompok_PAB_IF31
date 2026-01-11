import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isSignedIn = false;
  String fullName = '';
  String email = '';

  void logout (){
    setState(() {
      isSignedIn = !isSignedIn;
    });
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 200, width: double.infinity, color: Colors.blueAccent,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 200 - 50),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('images/placeholder_image.png')
                        ),
                      ),
                      if(isSignedIn)
                      IconButton(onPressed: () {},
                      icon: Icon(Icons.camera_alt, color: const Color.fromARGB(255, 17, 15, 15),),),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Divider(color: Colors.deepPurple[100],)
              ],
            ),
            )
        ],
      ),
    );
  }
  
}
