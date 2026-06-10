import 'user_creator.dart';

class MockUserCreator implements UserCreator {
  int _nextId;
  int callCount = 0;

  MockUserCreator({int firstId = 1}) : _nextId = firstId;

  @override
  Future<int> createUser(String username) async {
    callCount++;
    return _nextId++;
  }
}
