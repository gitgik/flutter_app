import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(new ChatApp());
}

const String _name = "Jee Gikera";

final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.amber,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light
);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.lightBlue,
  accentColor: Colors.amberAccent[400],
);


// extend stateless widget to define the UI
class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Chatter",
      theme: defaultTargetPlatform == TargetPlatform.iOS ?
        kIOSTheme : kDefaultTheme,
      home: new ChatScreen(),
    );
  }
}

/*
 Extend a widget that can has mutable state which can be read
 while the widget is built.
 */
class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.animationController});
  final String text;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
        parent: animationController, curve: Curves.bounceOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          // create a horizontal array of children
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
                margin: const EdgeInsets.only(right: 6.0),
                child: new CircleAvatar(child: new Text(_name[0]))
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(_name, style: Theme.of(context).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: new Text(text),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isChatting = false;

  Widget _buildTexter() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
                child: new TextField(
                  controller: _textController,
                  onChanged: (String text) {
                    setState(() { _isChatting = text.length > 0; });
                  },
                  onSubmitted: _handleSubmitted,
                  decoration: new InputDecoration.collapsed(hintText: "Send something..."),
                )
            ),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: _isChatting
                    ?  () => _handleSubmitted(_textController.text)
                    : null,
              ),
            ),
          ],
        )
      )
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Chatter"),
          elevation:
            Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0
        ),
        body: new Column(
          children: <Widget>[
            new Flexible(
                child: new ListView.builder(
                  padding: new EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, int index) => _messages[index],
                  itemCount: _messages.length,
                )
            ),
            new Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(
                  color: Theme.of(context).cardColor
              ),
              child: _buildTexter(),
            )
          ],
        )
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() { _isChatting = false; });

    ChatMessage message = new ChatMessage(
      text: text,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: 400),
        vsync: this),
    );
    // perform only synchronous operation and let the framework know that it
    // needs to rebuild the UI since the widget tree has changed
    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward(); // start running the animation forwards
  }

  /*
     Dispose animation controllers to free up resources when they are no longer
     needed.
   */
  @override
  void dispose() {
    for(ChatMessage message in _messages)
      message.animationController.dispose();
    super.dispose(); //called when the object is removed from tree permanently
  }
}
