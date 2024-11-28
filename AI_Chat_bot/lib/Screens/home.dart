// Added for background task scheduling
import 'dart:async';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  ChatUser currentuser = ChatUser(id: '0', firstName: "Guest");
  ChatUser geminiUser = ChatUser(
      id: '1',
      firstName: "AI",
      profileImage:
          "https://play-lh.googleusercontent.com/dT-r_1Z9hUcif7CDSD5zOdOt4KodaGdtkbGszT6WPTqKQ-WxWxOepO6VX-B3YL290ydD=w240-h480-rw");
  @override
  void initState() {
    super.initState();
    // Setup proactive task when app starts
    scheduleProactiveReminder();
  }

  void scheduleProactiveReminder() {
    Timer.periodic(const Duration(hours: 1), (timer) {
      String proactiveMessage =
          "Hey! Remember that the admission deadline is approaching soon.";
      ChatMessage reminderMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: proactiveMessage,
      );
      setState(() {
        messages = [reminderMessage, ...messages];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Chat with AI",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 44, 179, 233),
        elevation: 0,
      ),
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.8), BlendMode.dstATop),
              image: const NetworkImage(
                  'https://lh3.googleusercontent.com/gg/ACM6BIsxol59fllLR668Wcz5zPbSvHOk3_TaEOu9KjpekSP12yqJPWTM38XcmLsraqbs-Uyf_D2v5xenl3jVgaEaxaim8hR-EQGjVJzThpvKXVJlOSYWssuq3Eac_M5BQ41B7CE7W5gkMX52ljOC4xCAnsTRhgvymOobCGf5H50bxyOknt-oWqie'),
              fit: BoxFit.cover,
            ),
          ),
          child: _buildUI()),
    );
  }

  Widget _buildUI() {
    return DashChat(
      inputOptions: InputOptions(trailing: [
        IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              handleUserInput('regenerate'); // Detect regenerate command
            }),
        IconButton(
          onPressed: sendMediaMessage,
          icon: const Icon(Icons.image),
        )
      ]),
      currentUser: currentuser,
      onSend: sendMsg,
      messages: messages,
      messageOptions: MessageOptions(
        messageTextBuilder: (ChatMessage message, ChatMessage? previousMessage,
            ChatMessage? nextMessage) {
          if (message.user.id == geminiUser.id) {
            return MarkdownBody(data: message.text);
          } else {
            return Text(message.text);
          }
        },
      ),
    );
  }

  List<ChatMessage> conversationHistory = [];
  void sendMsg(ChatMessage chatMessage) {
    // Add the user's message to the conversation history
    conversationHistory.add(chatMessage);

    setState(() {
      messages = [chatMessage, ...messages];
    });

    try {
      String ques = chatMessage.text;

      gemini.streamGenerateContent(ques).listen((event) {
        String response = event.content?.parts
                ?.fold("", (prev, curr) => "$prev ${curr.text}") ??
            "";

        ChatMessage aiMessage = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: response, // AI response
        );

        // Add the AI's response to the conversation history
        conversationHistory.add(aiMessage);

        setState(() {
          messages = [aiMessage, ...messages];
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void regeneratePreviousResponse() {
    if (conversationHistory.isNotEmpty) {
      ChatMessage lastUserMessage = conversationHistory.lastWhere(
        (message) => message.user.id == currentuser.id,
      );

      sendMsg(lastUserMessage);
        }
  }

  void sendMsgWithContext() {
    String context = conversationHistory
        .map((message) => "${message.user.firstName}: ${message.text}")
        .join("\n");

    gemini.streamGenerateContent(context).listen((event) {
      String response = event.content?.parts
              ?.fold("", (prev, curr) => "$prev ${curr.text}") ??
          "";

      ChatMessage aiMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: response, // AI response considering full context
      );

      // Add the AI's response to the conversation history
      conversationHistory.add(aiMessage);

      setState(() {
        messages = [aiMessage, ...messages];
      });
    });
  }

  void sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
          user: currentuser,
          createdAt: DateTime.now(),
          text:
              "Describe this Picture and if any Questions are there then answer them?",
          medias: [
            ChatMedia(url: file.path, fileName: "", type: MediaType.image)
          ]);
      sendMsg(chatMessage);
    }
  }

  void handleUserInput(String userInput) {
    if (userInput.toLowerCase() == 'regenerate') {
      regeneratePreviousResponse();
    } else {
      // Handle normal messages
      ChatMessage chatMessage = ChatMessage(
        user: currentuser,
        createdAt: DateTime.now(),
        text: userInput,
      );
      sendMsg(chatMessage);
    }
  }
}
