import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {

  void setUpPushNotification() async{
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();

    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpPushNotification();
  }

  @override
  Widget build(BuildContext context) {

    final authUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chat').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator(),);
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty){
          return Center(child: Text('No messages'),);
        }

        if (snapshot.hasError){
          return Center(child: Text('Error Occurred'),);
        }

        final loadedMessages = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final currentMessage = loadedMessages[index].data();
            final nextMessage = index+1 < loadedMessages.length ? loadedMessages[index].data() : null;

            final currentUser = currentMessage['userID'];
            final nextUser = nextMessage == null ? null : nextMessage['userID'];

            final nextUserSame = currentUser == nextUser;

            if (nextUserSame){
              return MessageBubble.next(
                message: currentMessage['text'],
                isMe: authUser?.uid == currentUser,
              );
            }
            else{
              return MessageBubble.first(
                username: currentMessage['username'],
                message: currentMessage['text'],
                isMe: authUser?.uid == currentUser,
              );
            }
          },
        );
      },
    );
  }
}
