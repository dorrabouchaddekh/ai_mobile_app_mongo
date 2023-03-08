import 'package:ai_mobile_app/register/signin.dart';
import 'package:ai_mobile_app/register/signup.dart';
import 'package:flutter/material.dart';

import 'ai_chat_image/chat_screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),

      initialRoute: '/',
      routes: {

        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const Signin(),

        // When navigating to the "/signup" route, build the Signup widget.
        '/signup': (context) => const Signup(),

        // When navigating to the "/chatscreen" route, build the Chatscreen widget.
        '/chatscreen': (context) => const ChatScreen(),
      },

      // routes: {
      //   'app://': (context) => const Signup(),
      //   'app://signin': (context) => const Signin(),
      //   'app://chatscreen': (context) => const ChatScreen(),}
    );
  }
}
