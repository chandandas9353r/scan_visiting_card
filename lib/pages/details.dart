import 'package:flutter/material.dart';
import 'package:scan_visiting_card/components.dart';
import 'package:scan_visiting_card/services.dart' as services;

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

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)!.settings.arguments ??
        <String, dynamic>{}) as Map;
    services.User user = services.User(response: arguments['response']);
    return WillPopScope(
      onWillPop: () async => popScreen(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('USER DETAILS'),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20.0),
            ),
          ),
          elevation: 5,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder(
                    future: user.getUser(),
                    builder: (context, snapshot) {
                      return ListView.separated(
                        itemCount: user.detailsList.entries.length,
                        separatorBuilder: (context, index) {
                          return const Divider(
                            color: Colors.green
                          );
                        },
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
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
                GestureDetector(
                  onTap: () async {
                    services.EmailService emailService = services.EmailService();
                    await emailService.sendEmail(user.detailsList['email'][0].toString());
                  },
                  child: customComponents.customButton(
                    color: Colors.green,
                    child: customComponents.customText(
                      data: "Send Email",
                      color: Colors.white,
                      size: 20.0,
                    ),
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
