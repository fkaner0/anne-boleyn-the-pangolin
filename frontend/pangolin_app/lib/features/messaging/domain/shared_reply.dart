class SharedReply {
  final int senderId;
  final String text;
  final int datetime;

  const SharedReply({
    required this.senderId,
    required this.text,
    required this.datetime,
  });

  factory SharedReply.fromJson(Map<String, dynamic> json) {
    return SharedReply(
      senderId: json['senderId'] as int,
      text: (json['text'] as String?) ?? '',
      datetime: (json['datetime'] as num?)?.toInt() ?? 0,
    );
  }
}
