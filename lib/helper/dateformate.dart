import 'package:flutter/material.dart';

class MyDateUtlisP {
  static String getformattedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  // get last message time(used in chat user card)
  static String getTime({
    required BuildContext context,
    required String time,
  }) {
    final DateTime senttime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    // this is condition for messaage sent time
    if (now.day == senttime.day &&
        now.month == senttime.month &&
        now.year == senttime.year) {
      return TimeOfDay.fromDateTime(senttime).format(context);
    }
    // return showyear
    // ? '${senttime.day} ${_getmonth(senttime)} ${senttime.year}'
    return '${senttime.day} ${_getmonth(senttime)}';
  }

  // get formatated last active time of user in chat screen
  static String getLastActive(
      {required BuildContext context, required String lastActive}) {
    final int i = int.parse(lastActive);

    // // if time is not avalible then return below sattemant
    // if (i == -1) return 'Last sense not Avalialbe';

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formatedTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return "Today at $formatedTime";
    }
    if ((now.difference(time).inHours / 24).round() == 1) {
      return "yesterday at $formatedTime";
    }
    String month = _getmonth(time);
    return "${time.day} $month on $formatedTime ";
  }

  // this is for get month name
  static String _getmonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }
}
