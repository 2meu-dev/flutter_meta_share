import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_meta_share/flutter_meta_share.dart';

void main() async {
  await FlutterMetaShare().setPromotion(prefer: 120, max: 120);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  String lorem = '''
  'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.'
  ''';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Column(
                children: [
                  Spacer(),
                  OutlinedButton(onPressed: () {}, child: Text('share facebook')),
                  OutlinedButton(onPressed: () {}, child: Text('share instagram')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
