import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meta_share/flutter_meta_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? video;
  VideoPlayerController? controller;
  FlutterMetaShare share = FlutterMetaShare();

  @override
  void initState() {
    super.initState();
  }

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
                  if (controller != null) ...{
                    AspectRatio(
                      aspectRatio: 16/9,
                      child: VideoPlayer(
                        controller!,
                      ),
                    ),
                  },
                  OutlinedButton(
                      onPressed: () async {
                        bool isInstalled = await share.isFacebookInstalled();
                        debugPrint('isFacebookInstalled : $isInstalled');
                      },
                      child: Text('is facebook installed')),
                  OutlinedButton(
                      onPressed: () async {
                        bool isInstalled = await share.isInstagramInstalled();
                        debugPrint('isInstagramInstalled : $isInstalled');
                      },
                      child: Text('is instagram installed')),
                  OutlinedButton(
                      onPressed: () {
                        shareFacebook(isImage:true);
                      },
                      child: Text('share facebook(image)')),
                  OutlinedButton(
                      onPressed: () {
                        shareInstagram(isImage:true);
                      },
                      child: Text('share instagram(image)')),
                  OutlinedButton(
                      onPressed: () {
                        shareFacebook();
                      },
                      child: Text('share facebook(video)')),
                  OutlinedButton(
                      onPressed: () {
                        shareInstagram();
                      },
                      child: Text('share instagram(video)')),
                  SizedBox(height: 36),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void setController() async{
    controller = VideoPlayerController.file(video!);
    await controller?.initialize();
    setState(() {

    });
  }

  Future shareInstagram({bool? isImage}) async {
    File file;
    if(isImage ?? false){
      file = await getFileFromAssets('video/image-sample.png');
    }else{
      file = await getFileFromAssets('video/video-sample.mp4');
    }
    bool isSuccess = await share.shareInstagram(filePath: file.path);
    debugPrint('shareInstagram : $isSuccess');
  }

  Future shareFacebook({bool? isImage}) async {
    File file;
    if(isImage ?? false){
      file = await getFileFromAssets('video/image-sample.png');
    }else{
      file = await getFileFromAssets('video/video-sample.mp4');
    }
    bool isSuccess = await share.shareFacebook(filePath: file.path);
    debugPrint('shareFacebook : $isSuccess');
  }

  Future<File> getFileFromAssets(String path) async {
    ByteData byteData = await rootBundle.load('assets/$path');
    return writeToFile(byteData, '${(await getApplicationDocumentsDirectory()).path}/${path.split("/").last}');
  }

  Future<File> writeToFile(ByteData data, String path) {
    if (File(path).existsSync()) {
      File(path).deleteSync();
    }
    final buffer = data.buffer;
    debugPrint('write file $path');
    return File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
