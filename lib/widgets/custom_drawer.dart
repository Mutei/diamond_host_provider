import 'package:daimond_host_provider/extension/sized_box_extension.dart';
import 'package:daimond_host_provider/localization/language_constants.dart';
import 'package:daimond_host_provider/screens/notification_screen.dart';
import 'package:daimond_host_provider/screens/profile_screen.dart';
import 'package:daimond_host_provider/screens/request_screen.dart';
import 'package:daimond_host_provider/screens/upgrade_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../backend/log_out_method.dart';
import '../constants/colors.dart';
import '../main.dart';
import '../screens/all_posts_screen.dart';
import '../screens/provider_notification_screen.dart';
import '../screens/theme_settings_screen.dart';
import '../screens/type_estate_screen.dart';
import '../state_management/general_provider.dart';
import '../utils/global_methods.dart';
import 'item_drawer.dart';
import 'package:badges/badges.dart' as badges;

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

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
              padding:
                  const EdgeInsets.only(top: 20), // Reduce space above image
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 100, // Radius of the outer circle
                      backgroundColor:
                          Colors.transparent, // Transparent background
                    ),
                    ClipOval(
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: 160, // Exact width for the image
                        height: 160, // Exact height for the image
                        fit: BoxFit
                            .cover, // Ensures the image covers the circle area
                      ),
                    ),
                  ],
                ),
              ),
            ),

            DrawerItem(
              text: getTranslated(context, "Profile"),
              icon: Icon(Icons.person, color: kDeepPurpleColor),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ProfileScreenUser()));
              },
              hint: getTranslated(context, "You can view your data here"),
            ),
            DrawerItem(
              icon: Icon(Icons.add, color: kDeepPurpleColor),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TypeEstate(Check: "Add an Estate")));
              },
              hint: getTranslated(
                context,
                "From here you can add an estate.",
              ),
              text: getTranslated(
                context,
                "Add an Estate",
              ),
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
              text: getTranslated(
                context,
                "Notification",
              ),
              icon: Icon(Icons.notification_add, color: kDeepPurpleColor),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProviderNotificationScreen()));
              },
              hint: getTranslated(
                context,
                "You can see the notifications that come to you, such as booking confirmation",
              ),
            ),
            // DrawerItem(
            //   text: getTranslated(context, "Request"),
            //   icon: Icon(Bootstrap.book, color: kDeepPurpleColor),
            //   onTap: () {
            //     Navigator.of(context).push(
            //         MaterialPageRoute(builder: (context) => RequestScreen()));
            //   },
            //   hint:
            //       getTranslated(context, "Receive booking requests from here"),
            // ),
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
            // DrawerItem(
            //   text: getTranslated(context, "Arabic"),
            //   icon: Icon(Icons.language, color: kDeepPurpleColor),
            //   onTap: () async {
            //     SharedPreferences sharedPreferences =
            //         await SharedPreferences.getInstance();
            //     sharedPreferences.setString("Language", "ar");
            //     Locale newLocale = const Locale("ar", "SA");
            //     MyApp.setLocale(context, newLocale);
            //     Provider.of<GeneralProvider>(context, listen: false)
            //         .updateLanguage(false);
            //   },
            //   hint: "",
            // ),
            // DrawerItem(
            //   text: getTranslated(context, "English"),
            //   icon: Icon(Icons.language, color: kDeepPurpleColor),
            //   onTap: () async {
            //     SharedPreferences sharedPreferences =
            //         await SharedPreferences.getInstance();
            //     sharedPreferences.setString("Language", "en");
            //     Locale newLocale = const Locale("en", "SA");
            //     MyApp.setLocale(context, newLocale);
            //     Provider.of<GeneralProvider>(context, listen: false)
            //         .updateLanguage(true);
            //   },
            //   hint: '',
            // ),
            // DrawerItem(
            //     text: Provider.of<GeneralProvider>(context).isDarkMode
            //         ? getTranslated(context, "Light Mode")
            //         : getTranslated(context, "Dark Mode"), // Text for dark mode
            //     icon: Icon(
            //       Provider.of<GeneralProvider>(context).isDarkMode
            //           ? Icons.light_mode
            //           : Icons.dark_mode,
            //       color: kDeepPurpleColor,
            //     ),
            //     onTap: () {
            //       Provider.of<GeneralProvider>(context, listen: false)
            //           .toggleTheme();
            //     },
            //     hint: ''),
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
