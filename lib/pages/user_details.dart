import 'dart:io';
import 'dart:typed_data';
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
  HTTPService httpService = HTTPService(url: 'http://173.249.8.98');

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
      http.Response finalResponse = await httpService.postScannedImage(image, ':5005/parse');
      bool isSuccess = await httpService.postData(finalResponse, _image as File, ':5020/data');
      if(!isSuccess){
        _byteImage = null;
        _image = null;
        progress = false;
        setState(() {});
        return;
      }
      if(!mounted) return;
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
            child: Column(
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
                            color: Colors.white,
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
                            color: Colors.white,
                            size: 20.0,
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
                        color: Colors.white,
                        size: 20.0,
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
                            color: Colors.white,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (progress)
            customComponents.customButton(
              color: Colors.black54,
              margin: 0.0,
              radius: 0.0,
              padding: 0.0,
              child: const CircularProgressIndicator(),
            ),
        ],
      )),
    );
  }
}
