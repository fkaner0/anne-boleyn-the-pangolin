abstract interface class ButtonClickLogger {
  Future<void> logButtonClick({required int userId, required String buttonId});
}
