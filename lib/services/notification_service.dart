// TODO: notification service | Author: Rajat Mahajan
// Service: NotificationService — daily reminder push notifications

class NotificationService {
  // TODO: initialize flutter_local_notifications
  Future<void> init() async {
    // TODO: request permissions, set up notification channel
  }

  // TODO: schedule daily reminder at user's set time
  Future<void> scheduleDailyReminder(String time) async {
    // time format: 'HH:mm' e.g. '20:00'
    // TODO: parse time, schedule repeating notification
  }

  Future<void> cancelDailyReminder() async {
    // TODO: cancel scheduled notification
  }
}
