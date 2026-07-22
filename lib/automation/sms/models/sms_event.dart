/// Represents a parsed SMS event from the Android EventChannel bridge.
class SmsEvent {
  final String sender;
  final int timestamp;
  final String body;
  final String source;
  final String type;
  final int version;

  SmsEvent({
    required this.sender,
    required this.timestamp,
    required this.body,
    this.source = 'sms',
    this.type = 'sms_received',
    this.version = 1,
  });

  factory SmsEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return SmsEvent(
      sender: (data['sender'] as String?) ?? 'unknown',
      timestamp: (data['timestamp'] as int?) ?? 0,
      body: (data['body'] as String?) ?? '',
      source: 'sms',
      type: (json['event'] as String?) ?? 'sms_received',
      version: (json['version'] as int?) ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'event': type,
        'data': {
          'sender': sender,
          'timestamp': timestamp,
          'body': body,
        },
      };

  @override
  String toString() => 'SmsEvent(sender: $sender, timestamp: $timestamp, '
      'body: "${body.length > 50 ? '${body.substring(0, 50)}...' : body}")';
}
