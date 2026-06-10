import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/auth/auth_provider.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/button_click_logger.dart';
import 'package:pangolin_app/features/messaging/data/shared_board_service.dart';
import 'package:pangolin_app/theme/palette_colors.dart';
import '../../domain/profile.dart';
import '../../domain/profile_image.dart';
import '../../domain/profile_text.dart';
import '../widgets/bedroom_wall_detail_content.dart';
import '../widgets/message_composer.dart';
import '../widgets/profile_header_bar.dart';

class BedroomWallDetailPage extends ConsumerStatefulWidget {
  final Profile profile;
  final ProfileImage? image;
  final ProfileText? textbox;
  final ButtonClickLogger? logger;
  final SharedBoardService? sharedBoardService;

  const BedroomWallDetailPage({
    super.key,
    required this.profile,
    this.image,
    this.textbox,
    this.logger,
    this.sharedBoardService,
  }) : assert(
         image != null || textbox != null,
         'Either image or textbox must be provided.',
       );

  @override
  ConsumerState<BedroomWallDetailPage> createState() =>
      _BedroomWallDetailPageState();
}

class _BedroomWallDetailPageState extends ConsumerState<BedroomWallDetailPage> {
  late final TextEditingController _controller;
  late final SharedBoardService _sharedBoardService =
      widget.sharedBoardService ?? getIt<SharedBoardService>();
  int _currentUserId() =>
      ref.read(userIdProvider.notifier).currentUserIdThrow();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _log(String buttonId) {
    unawaited(
      (widget.logger ?? getIt<ButtonClickLogger>()).logButtonClick(
        userId: _currentUserId(),
        buttonId: buttonId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prompt = 'Talk to ${widget.profile.name} about this...';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ProfileHeaderBar(
              name: widget.profile.name,
              location: widget.profile.location,
              onBackPressed: () {
                _log(ButtonIds.wallDetailBack);
                Navigator.of(context).pop();
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colorScheme.outline),
                          boxShadow: [
                            BoxShadow(
                              color: context.paletteColors.shadow,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: BedroomWallDetailContent(
                            image: widget.image,
                            textbox: widget.textbox,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      MessageComposer(
                        hintText: prompt,
                        // TODO: make this tidier
                        onSend: (message) {
                          _log(ButtonIds.wallDetailSend);
                          widget.image != null
                              ? _sharedBoardService.sendImage(
                                  senderId: _currentUserId(),
                                  receiverId: widget.profile.userId,
                                  url: widget.image!.url,
                                  message: message,
                                )
                              : _sharedBoardService.sendText(
                                  senderId: _currentUserId(),
                                  receiverId: widget.profile.userId,
                                  text: widget.textbox!.body,
                                  message: message,
                                );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
