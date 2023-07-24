import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:scan_visiting_card/components.dart';
import 'package:scan_visiting_card/services.dart';
import 'package:http/http.dart' as http;

class UserDetails extends StatefulWidget {
  const UserDetails({super.key});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  CustomComponents customComponents = CustomComponents();
  ImageService imageService = ImageService();
  HTTPService httpExtractService = HTTPService(url: 'http://173.249.8.98');

  File? _image;
  Uint8List? _byteImage;
  bool isCamera = false;
  bool progress = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _image = null;
    _byteImage = null;
    progress = false;
    isCamera = false;
    isProcessing = false;
  }

  @override
  void dispose() {
    _image = null;
    _byteImage = null;
    progress = false;
    isCamera = false;
    isProcessing = false;
    super.dispose();
  }

  Future<void> postData() async {
    if (_image != null) {
      File image = _image as File;
      http.Response finalResponse =
          await httpExtractService.postScannedImage(image, ':5005/parse');
      if (!mounted) return;
      if (finalResponse.statusCode >= 200 && finalResponse.statusCode < 300) {
        http.Response response = await httpExtractService.postData(
            finalResponse, image, ':5020/data');
        if (!mounted) return;
        if (response.statusCode >= 200 && response.statusCode < 300) {
          Fluttertoast.showToast(
            msg: "SUCCESS",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: "FAILED",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        await Navigator.of(context).pushNamed(
          '/details',
          arguments: {
            'response': finalResponse,
          },
        );
        progress = false;
        _image = null;
        _byteImage = null;
        setState(() {});
      } else if (finalResponse.statusCode >= 500 &&
          finalResponse.statusCode < 600) {
        progress = false;
        _image = null;
        _byteImage = null;
        Fluttertoast.showToast(
          msg: "WRONG IMAGE",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        setState(() {});
      } else if (finalResponse.statusCode >= 400 &&
          finalResponse.statusCode < 500) {
        Fluttertoast.showToast(
          msg: 'SERVER ISSUE. PLEASE TRY AGAIN LATER',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        _byteImage = null;
        _image = null;
        progress = false;
        Fluttertoast.showToast(
          msg: "PLEASE TRY AGAIN",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: 9.0 / 16.0,
                            child: Container(
                              alignment: Alignment.center,
                              foregroundDecoration: BoxDecoration(
                                color: (isProcessing)
                                    ? Colors.black54
                                    : Colors.transparent,
                              ),
                              child: (_byteImage != null)
                                  ? Image.memory(_byteImage as Uint8List)
                                  : Container(),
                            ),
                          ),
                          if (isProcessing) const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () async {
                              _image = await imageService.getImage(true);
                              isCamera = true;
                              setState(() {});
                              _byteImage = (_image as File).readAsBytesSync();
                              setState(() {});
                            },
                            child: customComponents.customButton(
                              color: Colors.green,
                              child: customComponents.customText(
                                data: "Camera",
                                direction: TextDirection.ltr,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: GestureDetector(
                            onTap: () async {
                              _image = await imageService.getImage(false);
                              isCamera = false;
                              setState(() {});
                              _byteImage = (_image as File).readAsBytesSync();
                              setState(() {});
                            },
                            child: customComponents.customButton(
                              color: Colors.green,
                              child: customComponents.customText(
                                data: "Gallery",
                                size: 20.0,
                                direction: TextDirection.ltr,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_byteImage != null && !isCamera)
                      GestureDetector(
                        onTap: () {
                          progress = true;
                          setState(() {});
                          postData();
                        },
                        child: customComponents.customButton(
                          color: Colors.green,
                          child: customComponents.customText(
                            data: "Submit",
                            size: 20.0,
                            direction: TextDirection.ltr,
                          ),
                        ),
                      ),
                    if (_byteImage != null && isCamera)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  isProcessing = true;
                                  setState(() {});
                                  _byteImage = await imageService.rotateImage(
                                      _byteImage as Uint8List, 90);
                                  await (_image as File)
                                      .writeAsBytes(_byteImage as Uint8List);
                                  isProcessing = false;
                                  setState(() {});
                                },
                                child: customComponents.customButton(
                                  color: Colors.green,
                                  child: const Icon(
                                    Icons.rotate_90_degrees_cw_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  isProcessing = true;
                                  setState(() {});
                                  _byteImage = await imageService.rotateImage(
                                      _byteImage as Uint8List, -90);
                                  await (_image as File)
                                      .writeAsBytes(_byteImage as Uint8List);
                                  isProcessing = false;
                                  setState(() {});
                                },
                                child: customComponents.customButton(
                                  color: Colors.green,
                                  child: const Icon(
                                    Icons.rotate_90_degrees_ccw_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              progress = true;
                              setState(() {});
                              postData();
                            },
                            child: customComponents.customButton(
                              color: Colors.green,
                              child: customComponents.customText(
                                data: "Submit",
                                size: 20.0,
                                direction: TextDirection.ltr,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (progress)
            Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Colors.black54),
              child: const CircularProgressIndicator(),
            ),
        ],
      )),
    );
  }
}
