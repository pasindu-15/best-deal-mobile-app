import 'package:best_deal_app_v2/services/auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


Future<ImageSender> createImageSender(String imageBase64) async {
  final response = await http.post(
    Uri.https('best-deal-service-aggregator.uc.r.appspot.com','/best-deal/aggregator/v1/service-handler/searchProducts'),
    //Uri.https('webhook.site','/b796921a-c49c-4c44-9174-44269824f56b'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'imageBase64' : imageBase64,
    }),
  );

  //if (response.statusCode == 200) {
    return ImageSender.fromJson(jsonDecode(response.body));
  //} else {
  //  throw Exception("No Offers at the moment");
  //}
}

class ImageSender {
  final List<dynamic> data;
  final String resDesc;
  final String resCode;


  ImageSender({this.data, this.resDesc, this.resCode});


  factory ImageSender.fromJson(Map<String, dynamic> json) {
    return ImageSender(
      data: json['data'],
      resDesc: json['resDesc'],
      resCode: json['resCode'],
    );
  }
}

Future<ImagePickerSender> pickerImageSender(int productId) async {
  /*final response = await http.post(
    Uri.https('best-deal-service-aggregator.uc.r.appspot.com','/best-deal/aggregator/v1/service-handler/searchProducts'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, int>{
      'productId' : productId,
    }),
  );
  */

  final queryParameters = {
    'productId' : productId.toString(),
  };

  final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
  final headers_2 = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  };
  final response = await http.get(
    Uri.https('best-deal-service-aggregator.uc.r.appspot.com','best-deal/aggregator/v1/service-handler/getProductOffers', queryParameters),
      headers: headers_2,
  );

  //if (response.statusCode == 200) {
    return ImagePickerSender.fromJson(jsonDecode(response.body));
  //} else {
   // throw Exception("No Offers at the moment in this product");
  //}
}

class ImagePickerSender {
  final List<dynamic> data;
  final String resDesc;
  final String resCode;

  ImagePickerSender({this.data, this.resDesc, this.resCode});

  factory ImagePickerSender.fromJson(Map<String, dynamic> json) {
    return ImagePickerSender(
      data: json['data'],
      resDesc: json['resDesc'],
      resCode: json['resCode'],
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, @required this.auth, @required this.title}) : super(key: key);
  final String title;
  final AuthBase auth;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  Uint8List _imageBytes;
  Uint8List _outImageBytes;
  String _imageName;
  String _image64;
  String _appId;
  int _r;
  int _min = 100000;
  int _max = 10000000;
  int _productId ;
  String _shopName;
  String _itemType;
  String _selectPrdouctImage;
  Random _rnd;
  final picker = ImagePicker();
  // CloudApi api;
  bool isUploaded = false;
  bool loading = false;
  bool isBestDeal = false;
  Future<ImageSender> _futureImageSender;
  Future<ImagePickerSender> _futureImagePickerSender;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _signOut() async {
    try {
      await widget.auth.signOut();
    }catch(e){
      print(e.toString());
    }
  }


  void _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera, imageQuality: 50,);
    //final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        print(pickedFile.path);
        _image = File(pickedFile.path);
        _imageBytes = _image.readAsBytesSync();
        _imageName = _image.path.split('/').last;
        _rnd= new Random();
        _r = _min + _rnd.nextInt(_max - _min);
        _appId = '$_r';
        _image64 = base64.encode(_imageBytes);
        int v = base64.encode(_imageBytes).length;
        print('image size $v');
        isUploaded = false;
      } else {
        print('No image selected.');
      }
    });
  }


  void _saveImage() async {
    setState(() {
      loading = true;
    });
    setState(() {
      _futureImageSender= createImageSender(_image64);
      loading = false;
      isUploaded = true;
    });
  }

  void _confirmImage() async{
    setState(() {
      _futureImagePickerSender= pickerImageSender(_productId);
      loading = false;
      isUploaded = true;
      isBestDeal = true;
    });
  }

  void _goToHome() async {
    setState(() {
      isUploaded = false;
      loading = false;
      isBestDeal = false;
      _futureImageSender = null;
      _imageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          textAlign: TextAlign.center,
        ),
        leading : IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () { _goToHome(); },
          tooltip: MaterialLocalizations.of(context).showMenuTooltip,
        ),
        actions: <Widget>[
          FlatButton(
              onPressed: _signOut,
              child: Text('Logout', style:  TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),))
        ],
      ),
      body: Center(
          child: (_futureImageSender == null)
              ?_imageBytes == null
              ? Text('Click the Camera Button to Add Product Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600 ))
              : Stack(
            children: [
              Image.memory(_imageBytes),
              if (loading)
                Center(
                  child: CircularProgressIndicator(),
                ),
              isUploaded
                  ? Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              )
                  : Align(
                alignment: Alignment.bottomCenter,
                child: FlatButton(
                  color: Colors.blueAccent,
                  textColor: Colors.white,
                  onPressed: _saveImage,
                  child: Text('get Offer details'),
                ),
              )
            ],
          ) : (isBestDeal == false) ? FutureBuilder<ImageSender>(
            future: _futureImageSender,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if(snapshot.data.resCode!="00"){
                  return Text("No Offers at the moment in this product",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600 ));
              }
                return SingleChildScrollView(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Select Your Product from below images", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600 )),
                    for(int i=0; i < snapshot.data.data.length; i++)(
                        GestureDetector(
                          onTap: () {
                            print("Tap your product");
                            _productId = Map<String, dynamic>.from(snapshot.data.data[i])["id"];
                            _shopName = Map<String, dynamic>.from(snapshot.data.data[i])["shopName"];
                            _itemType = Map<String, dynamic>.from(snapshot.data.data[i])["itemType"];
                            _selectPrdouctImage = Map<String, dynamic>.from(snapshot.data.data[i])["image"];
                            _confirmImage();
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 5,
                                color: Colors.blueGrey,
                              ),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.memory(base64Decode(Map<String, dynamic>.from(snapshot.data.data[i])["image"])),
                                  Text("Item : " + Map<String, dynamic>.from(snapshot.data.data[i])["itemName"] ,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600 ),),
                                  Text(" Shop : " + Map<String, dynamic>.from(snapshot.data.data[i])["shopName"],
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600 ),),
                                ]
                        ),
                        )
                    )
                    )
                  ],
                ),
                );

              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return CircularProgressIndicator();
            },
          )
              : FutureBuilder<ImagePickerSender>(
            future: _futureImagePickerSender,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(child: Column(
                  //mainAxisAlignment: MainAxisAlignment.,
                  children: [
                    Text("Image of Product : " ,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900 ),),
                    Image.memory(base64Decode(_selectPrdouctImage)),
                    Text("Shop : " + _shopName,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600 ),),
                    SizedBox(height: 15.0,),
                    Text("These are the Offers for your product",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900 )),
                    SizedBox(height: 15.0,),
                    for(int i=0; i < snapshot.data.data.length; i++)(
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                    Text("Offer " + (i+1).toString() +" : ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800 ),),
                    GestureDetector(
                      onTap: () {
                        print("Tap the offer");
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 5,
                            color: Colors.blueGrey,
                          ),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              Text("  Bank : " + Map<String, dynamic>.from(snapshot.data.data[i])["bankName"] ,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600 ),),
                              Text("  Cards : " + Map<String, dynamic>.from(snapshot.data.data[i])["cardName"],
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600 ),),
                              Text("  Offer details : " + Map<String, dynamic>.from(snapshot.data.data[i])["offer"],
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600 ),),
                            ]
                      ),
                    )
                    )]
                    )
                    )
                  ],
                ),
                );

              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return CircularProgressIndicator();
            },
          )

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Select image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}