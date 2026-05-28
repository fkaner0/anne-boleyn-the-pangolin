abstract class ProfileRejectionDecider {
  Future<void> putProfileRejection({
    required int userId,
    required bool rejected,
  });
}
