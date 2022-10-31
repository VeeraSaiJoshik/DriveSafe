List<int> searchPhoneNumbers(
    List<String> phoneNumber, String queryText, bool haveAlreadyInitiated) {
  List<int> finalList = [];
  List<String> beginningList = [];
  if (double.tryParse(queryText) == null) {
    return [];
  }
  if (queryText == "" || !(haveAlreadyInitiated)) {
    for (int i = 0; i < phoneNumber.length; i++) {
      finalList.add(i);
    }
    return finalList;
  }

  List<String> tempList = [];
  List<String> tempList2 = [];
  tempList2.addAll(phoneNumber);
  for (int i = 0; i < 13 - queryText.length; i++) {
    int total = tempList2.length;
    tempList = [];
    for (int k = 0; k < total; k++) {
      if (tempList2[k].substring(i, i + queryText.length) == queryText) {
        tempList.add(tempList2[k]);
        tempList2.remove(tempList2[k]);
        k--;
        total--;
      }
    }
    tempList.sort();
    print(tempList);
    for (int l = 0; l < tempList.length; l++) {
      finalList.add(phoneNumber.indexOf(tempList[l]));
    }
  }
  return finalList;
}

List<int> searchNames(List<String> phoneNumber, String queryText, int Longest,
    bool haveAlreadyInitiated) {
  List<String> finalList = [];
  int highest = 0;
  List<int> answer = [];
  if (queryText == "" || !(haveAlreadyInitiated)) {
    for (int i = 0; i < phoneNumber.length; i++) {
      answer.add(i);
    }
    return answer;
  } else {
    List<String> tempList = [];
    List<String> tempList2 = [];
    tempList2.addAll(phoneNumber);
    for (int i = 0; i < Longest - queryText.length; i++) {
      int total = tempList2.length;
      tempList = [];
      for (int k = 0; k < total; k++) {
        if (tempList2[k].substring(i, i + queryText.length) == queryText) {
          tempList.add(tempList2[k]);
          tempList2.remove(tempList2[k]);
          k--;
          total--;
        }
      }
      tempList.sort();
      finalList = finalList + tempList;
    }
  }
  for (int i = 0; i < finalList.length; i++) {
    answer.add(phoneNumber.indexOf(finalList[i]));
  }
  return answer;
}
