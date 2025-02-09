import 'package:daimond_host_provider/localization/language_constants.dart';
import 'package:daimond_host_provider/screens/profile_screen.dart';
import 'package:daimond_host_provider/screens/request_screen.dart';
import 'package:daimond_host_provider/screens/upgrade_account_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import '../backend/log_out_method.dart';
import '../constants/colors.dart';
import '../screens/all_posts_screen.dart';
import '../screens/provider_notification_screen.dart';
import '../screens/theme_settings_screen.dart';
import '../screens/type_estate_screen.dart';
import '../state_management/general_provider.dart';
import '../utils/global_methods.dart';
import 'item_drawer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_database/firebase_database.dart'; // For Firebase interaction

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Future<bool> canAddEstate() async {
    final user =
        FirebaseAuth.instance.currentUser; // Get the authenticated user
    if (user == null) return true; // If user is null, allow adding an estate

    String userId = user.uid;
    print("My user id is: $userId"); // Print the Firebase user ID

    // List of estate categories to check
    List<String> estateCategories = ["Coffee", "Hottel", "Restaurant"];

    try {
      final DatabaseReference estateRef =
          FirebaseDatabase.instance.ref("App/Estate");

      for (String category in estateCategories) {
        final DatabaseReference categoryRef = estateRef.child(category);

        final DatabaseEvent event = await categoryRef.once();
        final DataSnapshot snapshot = event.snapshot;

        if (snapshot.exists && snapshot.value is Map<dynamic, dynamic>) {
          final estates = snapshot.value as Map<dynamic, dynamic>;

          for (var estate in estates.entries) {
            final estateData = estate.value as Map<dynamic, dynamic>;

            if (estateData['IDUser'] == userId) {
              print("User ID matches an estate in category: $category");

              if (estateData['IsAccepted'] == '1' ||
                  estateData['IsAccepted'] == '2') {
                print(
                    "Estate is accepted or under process. Cannot add another estate.");
                return false; // Estate is under process or accepted, cannot add another one
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching estate data: $e");
    }

    return true; // User can add an estate if no estate is found or all estates are rejected
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? kDarkModeColor
          : Colors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.transparent,
                    ),
                    ClipOval(
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            DrawerItem(
              text: getTranslated(context, "User's Profile"),
              icon: Icon(Icons.person, color: kDeepPurpleColor),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ProfileScreenUser()));
              },
              hint: getTranslated(context, "You can view your data here"),
            ),

            // Conditionally show "Add an Estate" button based on user estate status
            FutureBuilder<bool>(
              future: canAddEstate(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(); // Show nothing while checking
                }

                if (snapshot.hasData && snapshot.data == true) {
                  return DrawerItem(
                    icon: Icon(Icons.add, color: kDeepPurpleColor),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              TypeEstate(Check: "Add an Estate")));
                    },
                    hint: getTranslated(
                        context, "From here you can add an estate."),
                    text: getTranslated(context, "Add an Estate"),
                  );
                }

                return Container(); // Hide button if estate exists & is accepted/under process
              },
            ),

            DrawerItem(
              text: getTranslated(context, "Posts"),
              icon: Icon(Bootstrap.file_text, color: kDeepPurpleColor),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AllPostsScreen()));
              },
              hint: getTranslated(context, "Show the Post"),
            ),
            DrawerItem(
              text: getTranslated(context, "Notification"),
              icon: Icon(Icons.notification_add, color: kDeepPurpleColor),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProviderNotificationScreen()));
              },
              hint: getTranslated(context,
                  "You can see the notifications that come to you, such as booking confirmation"),
            ),
            Consumer<GeneralProvider>(
              builder: (context, provider, child) {
                return DrawerItem(
                  text: getTranslated(context, "Request"),
                  icon: Icon(Bootstrap.book, color: kDeepPurpleColor),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RequestScreen()));
                  },
                  hint: getTranslated(
                      context, "Receive booking requests from here"),
                  badge: provider.newRequestCount == 0
                      ? null
                      : badges.Badge(
                          badgeContent: Text(
                            provider.newRequestCount.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          child: Icon(
                            Bootstrap.book,
                            color: kDeepPurpleColor,
                          ),
                        ),
                );
              },
            ),
            DrawerItem(
              text: getTranslated(context, "Upgrade account"),
              icon: Icon(
                Icons.update,
                color: kDeepPurpleColor,
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UpgradeAccountScreen()));
              },
              hint: getTranslated(
                  context, "From here you can upgrade account to Vip"),
            ),
            DrawerItem(
              text: getTranslated(context, "Theme Settings"),
              icon: Icon(Icons.settings, color: kDeepPurpleColor),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingsScreen()));
              },
              hint: '',
            ),
            DrawerItem(
              text: getTranslated(context, "Logout"),
              icon: Icon(Icons.logout, color: kDeepPurpleColor),
              onTap: () {
                showLogoutConfirmationDialog(context, () async {
                  await LogOutMethod().logOut(context);
                });
              },
              hint: '',
            ),
          ],
        ),
      ),
    );
  }
}
