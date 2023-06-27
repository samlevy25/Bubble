import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AutomatedDBMSAPI {
  static String url = 'https://automated-dbms-rust.vercel.app/api?';

  static Future<void> userReq(String userUid) async {
    String requestUrl = '${url}request_type=user&user_uid=$userUid';
    if (kDebugMode) {
      print(requestUrl);
    }
    await _getRequest(requestUrl);
  }

  static Future<void> bubbleReq(String bubbleUid) async {
    String requestUrl = '${url}request_type=bubble&bubble_uid=$bubbleUid';
    if (kDebugMode) {
      print(requestUrl);
    }
    await _getRequest(requestUrl);
  }

  static Future<void> postReq(String postUid) async {
    String requestUrl = '${url}request_type=post&post_uid=$postUid';
    if (kDebugMode) {
      print(requestUrl);
    }
    await _getRequest(requestUrl);
  }

  static Future<void> commentReq(String postUid, String commentUid) async {
    String requestUrl =
        '${url}request_type=comment&post_uid=$postUid&comment_uid=$commentUid';
    if (kDebugMode) {
      print(requestUrl);
    }
    await _getRequest(requestUrl);
  }

  static Future<void> _getRequest(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return print(response.body);
    } else {
      throw Exception('Failed to make GET request');
    }
  }
}
