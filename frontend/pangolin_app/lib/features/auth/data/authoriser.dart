abstract class Authoriser {
  Future<int> getNewUserId(String username);

  Future<int> getExistingUserId(String username);
}
