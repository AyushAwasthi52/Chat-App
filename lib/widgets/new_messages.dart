import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {

  final _messageController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _messageController.dispose();
    super.dispose();
  }

  void send() async{
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty){
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();

    FirebaseFirestore.instance.collection('chat').add({
      'text' : enteredMessage,
      'createdAt' : DateTime.now(),
      'userID' : user?.uid,
      'username' : userData.data()!['username'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: const InputDecoration(label: Text('Enter message')),
            autocorrect: true,
            textCapitalization: TextCapitalization.sentences,
            enableSuggestions: true,
          ),
        ),
        IconButton(
          onPressed: send,
          icon: Icon(Icons.send),
          color: Theme.of(context).colorScheme.primary,
        )
      ],
    );
  }
}
