import 'dart:convert';

import 'package:http/http.dart';
import 'package:instagram_clone_firebase/models/member_model.dart';
import 'package:instagram_clone_firebase/services/log_service.dart';

import '../models/notification_model.dart';

class Network {
  static String SERVER_FCM = "fcm.googleapis.com";

  static Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization':
        'key=AAAA9qlYYMs:APA91bE423oaEtoRMLZ28geVAMxzyM4b-_bvmNBfrk8PniXFMHHtZajR7XZ0q81xERY-MmgdWamq7OT8P13g7LXj3qEej-tdQZct5sJAkI7WfMhPz9Cj1eNCnCjBPVmnHzHBZqpGxE5K'
  };

  /* Http Requests */

  static Future<String?> POST(String api, Map<String, dynamic> params) async {
    var uri = Uri.https(SERVER_FCM, api);
    var response = await post(uri, headers: headers, body: jsonEncode(params));
    if (response.statusCode == 200 || response.statusCode == 201) {
      LogService.i("resuqest rend");
      return response.body;
    }
    return null;
  }

  /* Http Apis*/
  static String API_SEND_NOTIF = "/fcm/send";

  /* Http Params */
  static Map<String, dynamic> paramsNotify(Member sender, Member receiver) {
    Notification notification = Notification(
        title: "Follow user", body: "${sender.fullname} started follow you");
    List<String>? ids = [receiver.device_token];
    NotificationModel model =
        NotificationModel(notification: notification, registrationIds: ids);
    return model.toJson();
  }

  static Map<String, dynamic> NotifyLike(Member sender, Member receiver) {
    Notification notification =
        Notification(title: "Like", body: "${sender.fullname} Liked your post");
    List<String>? ids = [receiver.device_token];
    NotificationModel model =
        NotificationModel(notification: notification, registrationIds: ids);
    return model.toJson();
  }
}
