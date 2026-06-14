import 'shared_reply.dart';

enum SharedElementKind { image, text }

class SharedElement {
  final int id;
  final int datetime;
  final SharedElementKind kind;
  final String content;
  final List<SharedReply> replies;
  final bool read;

  const SharedElement({
    required this.id,
    required this.datetime,
    required this.kind,
    required this.content,
    this.replies = const [],
    this.read = false,
  });

  bool get isImage => kind == SharedElementKind.image;

  SharedReply? get latestReply => replies.isEmpty ? null : replies.last;

  factory SharedElement.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String?;
    final text = json['text'] as String?;
    final isImage = url != null && url.isNotEmpty;

    return SharedElement(
      id: (json['sharedElemId'] as int?) ?? (json['id'] as int?) ?? 0,
      datetime: (json['datetime'] as num?)?.toInt() ?? 0,
      kind: isImage ? SharedElementKind.image : SharedElementKind.text,
      content: isImage ? url : (text ?? ''),
      replies:
          (json['messages'] as List<dynamic>?)
              ?.map((m) => SharedReply.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const [],
      read: ((json['unread'] as int?) ?? 0) > 0,
    );
  }
}
