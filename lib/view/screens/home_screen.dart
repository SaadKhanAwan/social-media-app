import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/view/screens/pages/activity.dart';
import 'package:social_media_app/view/screens/pages/profile.dart';
import 'package:social_media_app/view/screens/pages/search.dart';
import 'package:social_media_app/view/screens/pages/timeline.dart';
import 'package:social_media_app/view/screens/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_media_app/Controller/services/firebase_api.dart';

GoogleSignIn googleSignIn = GoogleSignIn();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController? controller;
  int pageIndex = 0;
  bool isloading = true;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: 0);
    APi.getSelfInfo().then((value) => setState(() {
          isloading = false;
        }));
  }

  @override
  void dispose() {
    super.dispose();
    controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : PageView(
              controller: controller,
              onPageChanged: onchengevalue,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const TimeLineScreen(),
                const ActivityFeedScreen(),
                UploadScreen(
                  users: APi.me,
                ),
                const SearchScreen(),
                ProfileScreen(me: APi.me),
              ],
            ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        activeColor: Colors.teal,
        onTap: ontab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded)),
        ],
      ),
    );
  }

  onchengevalue(int pageindex) {
    setState(() {
      pageIndex = pageindex;
    });
  }

  ontab(int pageindex) {
    controller!.animateToPage(pageindex,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }
}
