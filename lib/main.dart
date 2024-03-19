// ignore_for_file: non_constant_identifier_names

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:mesibo_flutter_sdk/mesibo.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

List<MesiboMessage> mesiboMessages = [];

class PushNotificationClient {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<RemoteMessage?> getInitialMessage() {
    return _fcm.getInitialMessage();
  }

  Future<void> _init() async {
    // the following  lines with line number 12-22 that are commented out does not affect the working of mesibo
    // so it doesn't matter if they are commented out or not

    // await _fcm.setForegroundNotificationPresentationOptions(
    //     alert: true, sound: true, badge: true);
    // FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');
    //   if (message.notification != null) {
    //     print('Message notification title: ${message.notification!.title}');
    //     print('Message notification body: ${message.notification!.body}');
    //   }
    // });

    // if we comment out below line then mesibo starts working normally
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<void> initialize() async {
    await _init();
  }

  static void handleMessage(RemoteMessage? message) {
    if (message == null) {
      return;
    }

    print(message.data);
  }

  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Title: ${message.notification?.title}');
    print('body: ${message.notification?.body}');
    print('payload: ${message.data}');

    handleMessage(message);
  }

  Future<String?> getToken() async {
    String? token = await _fcm.getToken();
    print('Token: $token');
    return token;
  }

  Future<void> deleteToken() async {
    return _fcm.deleteToken();
  }
}

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // here we initialize the push notifications
  await PushNotificationClient().initialize();
}

void main() async {
  await initApp();

  runApp(const FirstMesiboApp());
}

class FirstMesiboApp extends StatelessWidget {
  const FirstMesiboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mesibo Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("First Mesibo App"),
        ),
        body: const HomeWidget(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>
    implements MesiboConnectionListener, MesiboMessageListener {
  Mesibo mesibo = Mesibo();
  String mesiboStatus = 'Mesibo status: Not Connected.';
  bool isInit = false;
  MesiboProfile? selfProfile;
  MesiboProfile? remoteProfile;

  initProfiles() async {
    selfProfile = await mesibo.getSelfProfile() as MesiboProfile;
    remoteProfile = await mesibo.getUserProfile('35');
    isInit = true;
    setState(() {});
  }

  @override
  void Mesibo_onConnectionStatus(int status) {
    String statusText = status.toString();
    if (status == Mesibo.MESIBO_STATUS_ONLINE) {
      statusText = "Online";
      initProfiles();
    } else if (status == Mesibo.MESIBO_STATUS_CONNECTING) {
      statusText = "Connecting";
    } else if (status == Mesibo.MESIBO_STATUS_CONNECTFAILURE) {
      statusText = "Connect Failed";
    } else if (status == Mesibo.MESIBO_STATUS_NONETWORK) {
      statusText = "No Network";
    } else if (status == Mesibo.MESIBO_STATUS_AUTHFAIL) {
      statusText = "The token is invalid.";
    }
    mesiboStatus = 'Mesibo status: $statusText';
    setState(() {});
  }

  initMesibo() async {
    await mesibo.setAccessToken(
        '864b5bd17f61d46f826f59dbf1aed4d69a1fb6fc14915eff4ab25etaa336df1374');
    mesibo.setListener(this);
    await mesibo.setDatabase('55.db');
    await mesibo.restoreDatabase('55.db', 9999);
    MesiboReadSession rs = MesiboReadSession.createReadSummarySession(this);
    await rs.read(100);
    rs = MesiboReadSession.createReadSession(this);
    await rs.read(100);
    await mesibo.start();
  }

  @override
  void Mesibo_onMessage(MesiboMessage message) {
    mesiboMessages.add(message);
    setState(() {});
  }

  @override
  void Mesibo_onMessageStatus(MesiboMessage message) {
    print('Mesibo_onMessageStatus: ' + message.status.toString());
  }

  @override
  void Mesibo_onMessageUpdate(MesiboMessage message) {
    print('Mesibo_onMessageUpdate: ' + message.message!);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      initMesibo();
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Text(
              mesiboStatus,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          isInit
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          mesibo: mesibo,
                          selfProfile: selfProfile!,
                          remoteProfile: remoteProfile!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Chat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                       
                      ],
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.mesibo,
    required this.selfProfile,
    required this.remoteProfile,
  });
  final Mesibo mesibo;
  final MesiboProfile selfProfile;
  final MesiboProfile remoteProfile;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String remoteAdress = '35';
  late types.User _user;

  @override
  void initState() {
    _user = types.User(
      id: widget.selfProfile.address.toString(),
      firstName: widget.selfProfile.name,
    );
    super.initState();
  }

  _handleSendPressed(types.PartialText partialText) {
    MesiboMessage message = widget.remoteProfile.newMessage();
    message.message = partialText.text;
    mesiboMessages.add(message);
    message.send();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Chat(
      messages: mesiboMessages
          .map(
            (m) => types.TextMessage(
              author: types.User(id: m.profile?.address ?? ''),
              text: m.message ?? '',
              id: m.mid.toString(),
            ),
          )
          .toList(),
      onSendPressed: _handleSendPressed,
      user: _user,
    );
  }
}
