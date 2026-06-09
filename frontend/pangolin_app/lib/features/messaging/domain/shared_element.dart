import 'shared_reply.dart';

enum SharedElementKind { image, text }

class SharedElement {
  final int id;
  final int senderId;
  final int receiverId;
  final int datetime;
  final SharedElementKind kind;
  final String content;
  final List<SharedReply> replies;

  const SharedElement({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.datetime,
    required this.kind,
    required this.content,
    this.replies = const [],
  });

  bool get isImage => kind == SharedElementKind.image;

  bool involves(int a, int b) =>
      (senderId == a && receiverId == b) || (senderId == b && receiverId == a);

  SharedReply? get latestReply => replies.isEmpty ? null : replies.last;

  SharedElement withReply(SharedReply reply) {
    return SharedElement(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      datetime: datetime,
      kind: kind,
      content: content,
      replies: [...replies, reply],
    );
  }

  factory SharedElement.fromJson(Map<String, dynamic> json) {
    final kind = (json['type'] as String?) == 'text'
        ? SharedElementKind.text
        : SharedElementKind.image;

    return SharedElement(
      id: (json['id'] as int?) ?? (json['sharedElementId'] as int?) ?? 0,
      senderId: json['senderId'] as int,
      receiverId: json['receiverId'] as int,
      datetime: (json['datetime'] as int?) ?? 0,
      kind: kind,
      content: (json['url'] as String?) ?? (json['text'] as String?) ?? '',
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map(
                (item) => SharedReply.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }
}
