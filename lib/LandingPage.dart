import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Admin_pages/Admin_Login_Screen.dart';
import 'User_Page/User_login_page.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Select User Type'),
      // ),
      body:
      Center(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.white60,
              height: 190,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/image/img.png',
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 1,
              childAspectRatio: 5 / 1, // Adjust the aspect ratio as needed
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              padding: const EdgeInsets.all(10.0),
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: Colors.red,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Choose your preference",
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Admin Login Button
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 3 / 3, // Adjust the aspect ratio as needed
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              padding: const EdgeInsets.all(10.0),
              children: [
                GestureDetector(
                onTap: () {
            // Add navigation logic here to redirect to the login page
            Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginAdminScreen(),
            ),
                  );
                },
                  child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.green,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Login As an Admin",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
                  ),
                ),

                // User Login Button
                GestureDetector(
                  onTap: () {
                    // Add navigation logic here to redirect to the login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginUserScreen(),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5, // This controls the shadow depth
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.purple,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child:
                        Text(
                          "Login As an User",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}