import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';

class PhonelogsScreen extends StatefulWidget {
  @override
  _PhonelogsScreenState createState() => _PhonelogsScreenState();
}

class _PhonelogsScreenState extends State<PhonelogsScreen> with  WidgetsBindingObserver {
  //Iterable<CallLogEntry> entries;

  late Iterable<CallLogEntry> logs;

  @override
  void first()async{    logs = await CallLog.get();
}
  void initState(){
    // TODO: implement initState
    super.initState();
    first();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phone"),),
      body:Container()
    );
  }
}