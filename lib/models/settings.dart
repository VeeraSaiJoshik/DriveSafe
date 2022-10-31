class Settings {
  bool shareLocationToPhoneNumber = true;
  bool shareLocationToAllFriends = false;
  bool shareLocationToSelectedFriends = true;
  int sendMessageEverXMinutes = 5;
  bool sendSMS = false;
  bool offlineMode = false;
  bool locationSharingPeople = false;
  bool sleepDetection = false;
  bool blockCall = false;
  bool sendNotification = false;
  bool crashAlerts = true;
  bool trafficInfo = true;
  String messageReplyString = "I am currently driving. I will get back to you as soon as I can.";
  bool replyToIncomingSMS = true;
  bool includeEndTime = false;
  bool alertSpeeding = true;
  void jsonToSettings(Map jsonData) {
    if (jsonData.containsKey("shareLocationToPhoneNumber")) {
      shareLocationToPhoneNumber = jsonData["shareLocationToPhoneNumber"];
    }
    if(jsonData.containsKey("trafficInfo")){
      trafficInfo = jsonData["trafficInfo"];
    }
    if (jsonData.containsKey("messageReplyString")) {
      messageReplyString = jsonData["messageReplyString"];
    }
    if (jsonData.containsKey("replyToIncomingSMS")) {
      replyToIncomingSMS = jsonData["replyToIncomingSMS"];
    }
    if (jsonData.containsKey("includeEndTime")) {
      includeEndTime = jsonData["includeEndTime"];
    }
    if (jsonData.containsKey("sendMessageEverXMinutes")) {
      sendMessageEverXMinutes = jsonData["sendMessageEverXMinutes"];
    }
    if (jsonData.containsKey("shareLocationToAllFriends")) {
      shareLocationToAllFriends = jsonData["shareLocationToAllFriends"];
    }
    if (jsonData.containsKey("shareLocationToSelectedFriends")) {
      shareLocationToSelectedFriends =
          jsonData["shareLocationToSelectedFriends"];
    }
    if (jsonData.containsKey("sendSMS")) {
      sendSMS = jsonData["sendSMS"];
    }
    if (jsonData.containsKey("offlineMode")) {
      offlineMode = jsonData["offlineMode"];
    }
    if (jsonData.containsKey("locationSharingPeople")) {
      locationSharingPeople = jsonData["locationSharingPeople"];
    }
    if (jsonData.containsKey("sleepDetection")) {
      sleepDetection = jsonData["sleepDetection"];
    }
    if (jsonData.containsKey("blockCall")) {
      blockCall = jsonData["blockCall"];
    }
    if (jsonData.containsKey("sendNotification")) {
      sendNotification = jsonData["sendNotification"];
    }
    if (jsonData.containsKey("alertSpeeding")) {
      alertSpeeding = jsonData["alertSpeeding"];
    }
  }
}
