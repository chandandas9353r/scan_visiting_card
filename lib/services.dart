import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as parser;
import 'package:path/path.dart' as p;
import 'package:scan_visiting_card/model.dart' as model;

class HTTPService {
  String url;

  HTTPService({required this.url});

  Future<Uint8List> postImage(File image, String path) async {
    String fileExtension = p.extension(image.path);
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
    final data = jsonDecode(response.body.toString());
    String imageBytes = data['info']['scanned results']['rotated'].toString();
    imageBytes = imageBytes.replaceFirst("b'", '');
    imageBytes = imageBytes.replaceRange(
      imageBytes.length-1,
      imageBytes.length,
      ''
    );
    Uint8List decodedbytes = base64.decode(imageBytes);
    return decodedbytes;
  }

  Future<http.Response> postScannedImage(File image, String path) async {
    String fileExtension = p.extension(image.path);
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