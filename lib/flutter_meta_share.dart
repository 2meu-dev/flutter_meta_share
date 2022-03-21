import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterMetaShare {
  static const MethodChannel _channel = MethodChannel('flutter_meta_share');

  Future<bool> isInstagramInstalled() async {
    try {
      return await _channel.invokeMethod('is_instagram_installed') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isFacebookInstalled() async {
    try {
      return await _channel.invokeMethod('is_facebook_installed') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> shareFacebook({required String filePath}) async {
    try {
      return await _channel.invokeMethod('share_facebook', <String, dynamic>{
            'filePath': filePath,
          }) ??
          false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> shareInstagram({required String filePath}) async {
    try {
      return await _channel.invokeMethod('share_instagram', <String, dynamic>{
            'filePath': filePath,
          }) ??
          false;
    } catch (e) {
      return false;
    }
  }
}
