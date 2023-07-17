import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scan_visiting_card/components.dart';
import 'package:scan_visiting_card/services.dart' as services;
import 'package:flutter_email_sender/flutter_email_sender.dart' as sender;

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final CustomComponents customComponents = CustomComponents();

  bool popScreen(BuildContext context) {
    Navigator.of(context).pop(context);
    return true;
  }

  Future<void> sendEmail(String recepient) async {
    final sender.Email email = sender.Email(
      body: 'HELLO',
      subject: 'SCAN VISITING CARD',
      recipients: [recepient],
      isHTML: false,
    );
    try {
      await sender.FlutterEmailSender.send(email);
      Fluttertoast.showToast(msg: 'MAIL SENT');
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)!.settings.arguments ??
        <String, dynamic>{}) as Map;
    services.User user = services.User(response: arguments['response']);
    return WillPopScope(
      onWillPop: () async => popScreen(context),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                customComponents.customButton("USER DETAILS"),
                Expanded(
                  child: FutureBuilder(
                    future: user.getUser(),
                    builder: (context, snapshot) {
                      return ListView.builder(
                        itemCount: user.detailsList.entries.length + 1,
                        itemBuilder: (context, index) {
                          if (index == user.detailsList.entries.length) {
                            return GestureDetector(
                              onTap: () async => await sendEmail(
                                  snapshot.data!['email'][0].toString()),
                              child: Container(
                                margin: const EdgeInsets.all(10.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  "SEND EMAIL",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  snapshot.data!.keys
                                      .elementAt(index)
                                      .toString()
                                      .toUpperCase()
                                      .replaceAll('_', ' '),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  textAlign: TextAlign.end,
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(0.0),
                                      border: InputBorder.none),
                                  controller: TextEditingController(
                                      text: snapshot.data!.values
                                          .elementAt(index)
                                          .toString()
                                          .replaceAll('[', '')
                                          .replaceAll(']', '')),
                                  readOnly: true,
                                  showCursor: false,
                                  enableInteractiveSelection: true,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
