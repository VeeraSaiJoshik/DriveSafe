import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:drivesafev2/messageTesting.dart';
import 'package:drivesafev2/pages/Setting/settingsPage.dart';
import 'package:drivesafev2/pages/testing/visualTestScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:location/location.dart';
import 'package:telephony/telephony.dart';
import 'orientationDummyApp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/main_page.dart';
import 'pages/SignUpScreen.dart';
import 'package:drivesafev2/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'pages/LogInPage.dart';
import 'pages/ContactsScreen/FriendsScreen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'scheduled_channel',
        channelName: 'Scheduled Notifications',
        defaultColor: Colors.teal,
        locked: true,
        importance: NotificationImportance.High,
        channelDescription: "",
      ),
    ],
  );
  print(await FirebaseMessaging.instance.getToken());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  late int _totalNotificationCounter;
  Future<bool> getLocationAccess(Location location) async {
    bool serviceEnabled = false;
    PermissionStatus permissionGranted;
    serviceEnabled = await location.serviceEnabled();
    if (serviceEnabled == false) {
      serviceEnabled = await location.requestService();
      if (serviceEnabled == false) {
        return false;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void initStateFunction() async {
    bool? permissionGranted =
        await Telephony.instance.requestPhoneAndSmsPermissions;
    getLocationAccess(location);
    print("getting Action");
    bool? perG = await FlutterDnd.isNotificationPolicyAccessGranted;
    if (perG == false) {
      FlutterDnd.gotoPolicySettings();
    }
  }

  Location location = Location();
  void initState() {
    initStateFunction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void thing() {}
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return OverlaySupport(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: "Nunito",
        ),
        debugShowCheckedModeBanner: false,
        home: mainPage(),
        routes: {
          "mainPage": ((context) => mainPage()),
          "SignUpPage": ((context) => SignUpScreen()),
          "LogInPage": ((context) => LogInScreen()),
          "VisualTest": ((context) => VisualTest()),
        },
      ),
    );
  }
}
