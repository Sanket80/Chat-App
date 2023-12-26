import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {

    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages yet! Start sending some!'),
          );
        }
        final chatDocs = chatSnapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) {
            final chatDoc = chatDocs[index].data() as Map<String, dynamic>;
            final nextChatDoc = index + 1 < chatDocs.length
                ? chatDocs[index + 1].data() as Map<String, dynamic>?
                : null;

            final currentMessageUserId = chatDoc?['username'];
            final nextMessageUserId = nextChatDoc != null
                ? nextChatDoc['username']
                : null;
            final nextUserIsSame = currentMessageUserId == nextMessageUserId;

            if(nextUserIsSame){
              return MessageBubble.next(
                message: chatDoc['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }
            else{
              return MessageBubble.first(
                userImage: chatDoc['userImage'],
                username: chatDoc['username'],
                message: chatDoc['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }
          }
        );
      },
    );
  }
}
