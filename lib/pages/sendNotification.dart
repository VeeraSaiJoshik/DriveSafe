import 'dart:convert';
import 'package:http/http.dart' as http;

void sendNotification(String title, List<String> tokens, String body) {
  String apiKey = "Insert Firebase API Key";
  for (int i = 0; i < tokens.length; i++) {
      http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=' + apiKey,
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body':
                  body,//"Veera Unnam has been reported to be speeding. He is currently speeding in SW BoilerMaker RD, Bentonville, Arkansas. The speed limit is 25 MPH, he is going 30 MPH. Do you want to redirect to see his activity.",
              'title': title//"Speeding Alert"
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to":
                tokens[i],
          },
        ),
      );
  }
}
