import 'authoriser.dart';

class MockAuthoriser implements Authoriser {
  int _nextId;
  int callCount = 0;

  MockAuthoriser({int firstId = 1}) : _nextId = firstId;

  @override
  Future<int> getNewUserId(String username) async {
    callCount++;
    return _nextId++;
  }

  @override
  Future<int> getExistingUserId(String username) async {
    return 1;
  }
}
