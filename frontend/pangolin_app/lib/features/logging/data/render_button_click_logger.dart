import 'package:pangolin_app/config/env.dart';

import 'api_button_click_logger.dart';
import 'button_click_logger.dart';

class RenderButtonClickLogger implements ButtonClickLogger {
  final ApiButtonClickLogger _delegate;

  RenderButtonClickLogger({
    String host = defaultRenderHost,
    int? port,
    bool useHttps = true,
  }) : _delegate = ApiButtonClickLogger(
         host: host,
         port: port,
         useHttps: useHttps,
       );

  @override
  Future<void> logButtonClick({required int userId, required String buttonId}) {
    return _delegate.logButtonClick(userId: userId, buttonId: buttonId);
  }
}
