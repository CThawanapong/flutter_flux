// Copyright 2016, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

import 'stores.dart';

void main() {
  runApp(new MaterialApp(
      title: "Firechat",
      theme: new ThemeData(
          primarySwatch: Colors.purple, accentColor: Colors.orangeAccent[400]),
      home: new ChatScreen()));
}

class ChatScreen extends StoreWatcher {
  ChatScreen({Key key}) : super(key: key);

  void initState(ListenToStore listenToStore) {
    listenToStore(messageStoreToken);
    listenToStore(userStoreToken);
  }

  Widget _buildTextComposer(
      BuildContext context, MessageStore messageStore, UserStore userStore) {
    final commitMessage = (_) {
      commitCurrentMessageAction(userStore.me);
    };

    ThemeData themeData = Theme.of(context);
    return new Row(children: <Widget>[
      new Flexible(child: new Input(
          value: messageStore.CurrentMessage,
          hintText: 'Enter message',
          onSubmitted: commitMessage,
          onChanged: setCurrentMessageAction)),
      new Container(
          margin: new EdgeInsets.symmetric(horizontal: 4.0),
          child: new IconButton(
              icon: Icons.send,
              onPressed:
                  messageStore.isComposing ? () => commitMessage(null) : null,
              color: messageStore.isComposing
                  ? themeData.accentColor
                  : themeData.disabledColor))
    ]);
  }

  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    final messageStore = stores[messageStoreToken];
    final chatUserStore = stores[userStoreToken];

    return new Scaffold(
        appBar:
            new AppBar(title: new Text("Chatting as ${chatUserStore.me.name}")),
        body: new Column(children: <Widget>[
          new Flexible(child: new Block(
              padding: new EdgeInsets.symmetric(horizontal: 8.0),
              scrollAnchor: ViewportAnchor.end,
              children: messageStore.messages
                  .map((m) => new ChatMessageListItem(m))
                  .toList())),
          _buildTextComposer(context, messageStore, chatUserStore),
        ]));
  }
}

class ChatMessageListItem extends StatefulWidget {
  ChatMessageListItem(ChatMessage m)
      : super(key: new ObjectKey(m)),
        message = m;

  final ChatMessage message;

  State createState() => new ChatMessageListItemState();
}

class ChatMessageListItemState extends State<ChatMessageListItem> {
  ChatMessageListItemState() {
    _animation = new CurvedAnimation(
        parent: _animationController, curve: Curves.easeOut);
    _animationController.forward();
  }

  AnimationController _animationController =
      new AnimationController(duration: new Duration(milliseconds: 700));
  Animation _animation;

  Widget build(BuildContext context) {
    final message = config.message;
    return new SizeTransition(
        sizeFactor: _animation,
        axisAlignment: 0.0,
        child: new ListItem(
            dense: true,
            leading: new CircleAvatar(
                child: new Text(message.sender.name[0]),
                backgroundColor: message.sender.color),
            title: new Text(message.sender.name),
            subtitle: new Text(message.text)));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
