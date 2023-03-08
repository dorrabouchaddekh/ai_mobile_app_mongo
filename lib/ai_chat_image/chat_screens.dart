import 'package:ai_mobile_app/ai_chat_image/three_dots.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:async';
import 'chat_messages.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late OpenAI? chatGPT;

  StreamSubscription? _subscription;

  bool _isImageSearch = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    chatGPT = OpenAI.instance
        .build(token: "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");
  }

  @override
  void dispose() {
    chatGPT?.close();
    chatGPT?.genImgClose();
    _subscription?.cancel();
    super.dispose();
  }

  // Link for api - https://beta.openai.com/account/api-keys

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    ChatMessage message = ChatMessage(
      text: _controller.text,
      sender: "user",
      isImage: false,
    );

    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    _controller.clear();

    if (_isImageSearch) {
      final request = GenerateImage(message.text, 1, size: "256x256");
      chatGPT!
          .generateImage(request)
          .then((value) {
        insertNewData(value!.data!.first!.url!, isImage: true);
      });
    } else {
      final request = CompleteText(
          prompt: message.text, model: kTranslateModelV3, maxTokens: 200);

      chatGPT!.onCompleteText(request: request).then((value) {
        insertNewData(value!.choices.first.text);
      });
    }
  }

  Future<void> insertNewData(String response, {bool isImage = false}) async {
    ChatMessage botMessage =
        ChatMessage(text: response, sender: "bot", isImage: isImage);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Vx.log("helloo are you there?");
    Vx.log(prefs.getString("lastResponse"));

    await prefs.setString("lastResponse", response);

    Vx.log("is this the response?");
    Vx.log(response);

    setState(() {
      _isTyping = false;
      _messages.insert(0, botMessage);
    });

    try {
      final responseData = {'image': response};
      final json = jsonEncode(responseData);
      Vx.log("This is the json");
      Vx.log(json);

      final res = await http
          .post(
            Uri.parse('http://10.0.2.2:8080/api/images/add'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json,
          )
          .timeout(Duration(seconds: 10));
      if (res.statusCode == 201) {
        // The data was sent successfully to the server
        Vx.log("Data sent to server");
      } else {
        // There was an error sending the data to the server
        Vx.log("Failed to send data to server");
      }
    } catch (error) {
      // There was an error sending the data to the server
      Vx.log("Error sending data to server: $error");
    }
  }

  // Future<String?> getLastResponse() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString("lastResponse");
  // }

  // void insertNewData(String response, {bool isImage = false}) {
  //   ChatMessage botMessage =
  //       ChatMessage(text: response, sender: "bot", isImage: isImage);

  //   setState(() {
  //     _isTyping = false;
  //     _messages.insert(0, botMessage);
  //   });
  // }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            //onSubmitted: (value) => _sendMessage(),
            decoration: const InputDecoration.collapsed(
                hintText: "Question/description"),
          ),
        ),
        ButtonBar(
          children: [
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                _isImageSearch = false;
                _sendMessage();
              },
            ),
            TextButton(
                onPressed: () {
                  _isImageSearch = true;
                  _sendMessage();
                },
                child: const Text("Generate Image"))
          ],
        ),
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("AI Demo")),
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                  child: ListView.builder(
                reverse: true,
                padding: Vx.m8,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              )),
              if (_isTyping) const ThreeDots(),
              const Divider(
                height: 1.0,
              ),
              Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                ),
                child: _buildTextComposer(),
              )
            ],
          ),
        ));
  }
}
