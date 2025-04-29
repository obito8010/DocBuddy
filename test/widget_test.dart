import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ✅ Replace with your actual Groq API Key
const String groqApiUrl = "https://api.groq.com/v1/chat/completions";
const String groqApiKey = "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";

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  Future<void> sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      messages.add({'sender': 'user', 'text': message});
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(groqApiUrl), // ✅ Using Groq API URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $groqApiKey', // ✅ API Key for Authentication
        },
        body: jsonEncode({
          "model": "deepseek-r1-distill-llama-70b", // ✅ Groq Model
          "messages": [
            {"role": "system", "content": "You are a helpful medical assistant."},
            {"role": "user", "content": message}
          ],
          "temperature": 0.6,
          "max_tokens": 4096,
          "top_p": 0.95,
          "stream": false, // ❌ Flutter doesn't support streaming easily
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String botReply = responseData["choices"][0]["message"]["content"];

        setState(() {
          messages.add({'sender': 'bot', 'text': botReply});
        });
      } else {
        setState(() {
          messages.add({'sender': 'bot', 'text': "Error: ${response.statusCode} - ${response.body}"}); 
        });
      }
    } catch (e) {
      setState(() {
        messages.add({'sender': 'bot', 'text': "Network error: $e"});
      });
    }

    setState(() {
      isLoading = false;
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat with DocBuddy')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ChatBubble(
                  text: msg['text']!,
                  isUser: msg['sender'] == 'user',
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () => sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
