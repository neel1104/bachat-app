import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

import 'screen_msg_detail.dart';

class MySmsMessage {
  final SmsMessage smsMessage;

  // Add your custom attributes
  bool isTransactionMessage;

  // Constructor to initialize the wrapped SmsMessage and custom attributes
  MySmsMessage({
    required this.smsMessage,
    required this.isTransactionMessage,
  });

  // Delegate getters to the wrapped SmsMessage
  int? get id => smsMessage.id;

  int? get threadId => smsMessage.threadId;

  String? get address => smsMessage.address;

  String? get body => smsMessage.body;

  bool? get read => smsMessage.read;

  DateTime? get date => smsMessage.date;

  DateTime? get dateSent => smsMessage.dateSent;

  SmsMessageKind? get kind => smsMessage.kind;

  SmsMessageState get state => smsMessage.state;
}

extension SmsMessageExtension on List<SmsMessage> {
  List<MySmsMessage> toMySmsMessages() {
    List<MySmsMessage> ret = [];
    for (var msg in this) {
      var regexp1 = RegExp(
          r'A transactions of ([A-Z]{3}) ([\d.]+) was made with your UOB Card ending (\d+) on ([\d/]+) at (.+?)\. If');
      var regexp2 = RegExp(
          r'You made a (NETS QR payment|PayNow transfer) of ([A-Z]{3}) ([\d.]+) to (.+?) on your a/c ending \d+ at (.+?)\. If');
      ret.add(MySmsMessage(
          smsMessage: msg,
          isTransactionMessage:
              regexp1.hasMatch(msg.body!) || regexp2.hasMatch(msg.body!)));
    }
    return ret;
  }
}

class RawMessagesTab extends StatefulWidget {
  const RawMessagesTab({super.key});

  @override
  State<RawMessagesTab> createState() => _RawMessagesTabState();
}

class _RawMessagesTabState extends State<RawMessagesTab>
    with AutomaticKeepAliveClientMixin {
  final SmsQuery _query = SmsQuery();
  List<MySmsMessage> _messages = [];
  final String sender = 'UOB';
  final int queryLimit = 20;

  @override
  void initState() {
    super.initState();
    _initMessages();
  }

  Future<bool> _ensurePermission() async {
    var permission = await Permission.sms.status;
    var havePermission = permission.isGranted;
    if (!havePermission) {
      await Permission.sms.request();
    }
    return havePermission;
  }

  Future<void> _loadMessages() async {
    final messages = await _query.querySms(
      kinds: [
        SmsQueryKind.inbox,
      ],
      address: sender,
      count: queryLimit,
      sort: true,
    );
    debugPrint('sms inbox messages: ${messages.length}');
    setState(() => _messages = messages.toMySmsMessages());
  }

  void _initMessages() async {
    if (!await _ensurePermission()) {
      return null;
    }
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: _messages.isNotEmpty
          ? _RawMessagesListView(
              messages: _messages,
            )
          : Center(
              child: Text(
                'No messages matching the sender $sender',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => false;
}

void showSnackBar(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
  ));
}

class _RawMessagesListView extends StatelessWidget {
  const _RawMessagesListView({
    required this.messages,
  });

  final List<MySmsMessage> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int i) {
          MySmsMessage message = messages[i];

          return Card(
            child: ListTile(
              title: Text('${message.address} [${message.date}]'),
              subtitle: Text('[${message.threadId}] \n ${message.body}'),
              onTap: () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MsgDetailScreen(sms: message))),
              },
            ),
          );
        });
  }
}
