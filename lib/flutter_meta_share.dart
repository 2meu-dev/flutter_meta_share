import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class FlutterMetaShare {
  static const MethodChannel _channel = MethodChannel('flutter_meta_share');

  Future<bool> setPromotion({double? max = 60, double? prefer = 60}) async {
    try {
      if (Platform.isIOS) {
        return await _channel.invokeMethod('set_promotion', <String, dynamic>{
          'prefer': prefer,
          'max': max,
        }) ?? false;
      } else {
        return false;
      }
    }catch(e){
      return false;
    }
  }
}
