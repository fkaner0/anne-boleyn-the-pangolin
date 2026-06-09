import 'button_click_logger.dart';

class LoggedButtonClick {
  final int userId;
  final String buttonId;

  const LoggedButtonClick({required this.userId, required this.buttonId});
}

class MockButtonClickLogger implements ButtonClickLogger {
  final List<LoggedButtonClick> clicks = [];

  @override
  Future<void> logButtonClick({
    required int userId,
    required String buttonId,
  }) async {
    clicks.add(LoggedButtonClick(userId: userId, buttonId: buttonId));
  }
}
