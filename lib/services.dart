import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as parser;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as provider;
import 'package:edge_detection/edge_detection.dart' as detector;
import 'package:scan_visiting_card/model.dart' as model;
import 'package:flutter_email_sender/flutter_email_sender.dart' as sender;
import 'package:fluttertoast/fluttertoast.dart' as toast;

class ImageService{
  Future<File?> getImage() async {
    String imagePath = join(
        (await provider.getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.png");
    bool imageStored = await detector.EdgeDetection.detectEdge(
      imagePath,
      androidScanTitle: "Capture an Image",
      androidCropTitle: "Enhance the Image",
    );
    if (!imageStored) return null;
    return File(imagePath);
  }
}

class HTTPService {
  String url;

  HTTPService({required this.url});

  Future<http.Response> postScannedImage(File image, String path) async {
    String fileExtension = extension(image.path);
    fileExtension = fileExtension.split('.')[1];
    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url + path));
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: parser.MediaType('application', fileExtension),
      ),
    );
    http.StreamedResponse res = await request.send();
    http.Response response = await http.Response.fromStream(res);
    return response;
  }

  Future<bool> postData(http.Response finalResponse, File image, String path) async {
    if (finalResponse.statusCode >= 200 && finalResponse.statusCode < 300) {
      String fileExtension = extension(image.path);
      fileExtension = fileExtension.split('.')[1];
      Map map = {
        "data" : '"${finalResponse.body.toString()}"',
        "filename" : '"output.$fileExtension"',
        "file" : '''"b'${base64.encode(image.readAsBytesSync())}'"''',
      };
      http.Response response = await http.post(
        Uri.parse(url+path),
        headers: {"Content-Type": "application/json"},
        body: json.encode(map),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        toast.Fluttertoast.showToast(
          msg: "SUCCESS",
          toastLength: toast.Toast.LENGTH_LONG,
          gravity: toast.ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        toast.Fluttertoast.showToast(
          msg: "FAILED",
          toastLength: toast.Toast.LENGTH_LONG,
          gravity: toast.ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      return true;
    } else if (finalResponse.statusCode >= 500 &&
        finalResponse.statusCode < 600) {
      toast.Fluttertoast.showToast(
        msg: "WRONG IMAGE",
        toastLength: toast.Toast.LENGTH_LONG,
        gravity: toast.ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    } else if (finalResponse.statusCode >= 400 &&
        finalResponse.statusCode < 500) {
      toast.Fluttertoast.showToast(
        msg: 'SERVER ISSUE. PLEASE TRY AGAIN LATER',
        toastLength: toast.Toast.LENGTH_LONG,
        gravity: toast.ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    } else {
      toast.Fluttertoast.showToast(
        msg: "PLEASE TRY AGAIN",
        toastLength: toast.Toast.LENGTH_LONG,
        gravity: toast.ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
  }
}

class User{
  Map<String,dynamic> detailsList = {};
  http.Response response;

  User({required this.response});

  Future<Map<String,dynamic>> getUser() async {
    detailsList.clear();
      final data = await jsonDecode((response).body.toString())['info'];
      for(Map<String,dynamic> i in data.cast()){
        model.Model user = model.Model(
          name: i['name'],
          address: i['address'],
          phoneNumber: i['phone_number'],
          fax: i['fax'],
          email: i['email'],
          designation: i['designation'],
          companyName: i['company_name'],
          website: i['website'],
        );
        detailsList.addEntries(user.toJson().entries);
      }
    return detailsList;
  }
}

class EmailService{
  Future<void> sendEmail(String recepient) async {
    final sender.Email email = sender.Email(
      body: 'HELLO',
      subject: 'SCAN VISITING CARD',
      recipients: [recepient],
      isHTML: false,
    );
    try {
      await sender.FlutterEmailSender.send(email);
      toast.Fluttertoast.showToast(msg: 'MAIL SENT');
    } catch (e) {
      toast.Fluttertoast.showToast(msg: e.toString());
    }
  }
}